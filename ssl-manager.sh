#!/bin/bash
set -euo pipefail

# Source user configuration
if [[ -f "$HOME/.wsl_env" ]]; then
  source "$HOME/.wsl_env"
else
  echo "ERROR: ~/.wsl_env not found. Please run the setup installer first." >&2
  exit 1
fi

# Validate variables
: "${WEB_ROOT:?ERROR: WEB_ROOT is not set.}"
: "${SSL_DIR:?ERROR: SSL_DIR is not set.}"

# ─────────────────────────────────────────────────────────────────
# Only run if project-folder set has changed since last run
# ─────────────────────────────────────────────────────────────────
HASH_FILE="$HOME/.wsl_projects.hash"
# List only first‑level dirs, sort them, hash the list
CURRENT_HASH=$(find "$WEB_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' \
               | sort \
               | sha256sum \
               | awk '{print $1}')

if [[ -f "$HASH_FILE" && "$(cat "$HASH_FILE")" == "$CURRENT_HASH" ]]; then
  echo "🔎 No changes in $WEB_ROOT. Skipping SSL & vhost regeneration."
  exit 0
fi

# Save the new state
echo "$CURRENT_HASH" >"$HASH_FILE"
echo "🔄 Detected change in projects, running SSL & vhost manager..."

# Validate variables
if [[ -z "${WEB_ROOT:-}" ]]; then
  echo "ERROR: WEB_ROOT is not set." >&2
  exit 1
fi

if [[ -z "${SSL_DIR:-}" ]]; then
  echo "ERROR: SSL_DIR is not set." >&2
  exit 1
fi

# Paths
CA_DIR="$SSL_DIR/ca"
CA_KEY="$CA_DIR/rootCA.key"
CA_CERT="$CA_DIR/rootCA.pem"
NGINX_SITES_AVAILABLE="/etc/nginx/sites-available"
NGINX_SITES_ENABLED="/etc/nginx/sites-enabled"
HOSTS_FILE="/mnt/c/Windows/System32/drivers/etc/hosts"
WIN_HOSTS_FILE="C:\Windows\System32\drivers\etc\hosts"

CERT_KEY="$SSL_DIR/laragon.test.key"
CERT_CRT="$SSL_DIR/laragon.test.crt"
CERT_CSR="$SSL_DIR/laragon.test.csr"
CERT_CNF="$SSL_DIR/laragon.test.cnf"
CERT_BUNDLE="$SSL_DIR/laragon-bundle.crt"

# Ensure directories
mkdir -p "$SSL_DIR" "$CA_DIR"

echo "🔐 Creating or reusing Root CA..."
if [[ ! -f "$CA_KEY" || ! -f "$CA_CERT" ]]; then
  openssl genrsa -out "$CA_KEY" 2048
  openssl req -x509 -new -nodes -key "$CA_KEY" -sha256 -days 3650 \
    -out "$CA_CERT" -subj "/C=US/ST=WSL/L=Dev/O=Laragon/CN=Laragon Test CA"
  sudo cp "$CA_CERT" /usr/local/share/ca-certificates/laragon-rootCA.crt
  sudo update-ca-certificates
else
  echo "✅ Reusing existing root CA"
fi

echo "🔧 Building SAN config..."
cat >"$CERT_CNF" <<EOF
[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = *.test
EOF

i=2
for dirpath in "$WEB_ROOT"/*/; do
  site=$(basename "${dirpath%/}")
  echo "DNS.$i = ${site}.test" >>"$CERT_CNF"
  ((i++))
done

echo "🔐 Generating key and CSR..."
openssl req -new -newkey rsa:2048 -nodes \
  -keyout "$CERT_KEY" -out "$CERT_CSR" \
  -subj "/C=US/ST=WSL/L=Dev/O=Laragon/CN=*.test"

echo "✅ Signing cert with CA..."
openssl x509 -req -in "$CERT_CSR" -CA "$CA_CERT" -CAkey "$CA_KEY" \
  -CAcreateserial -out "$CERT_CRT" -days 825 -sha256 \
  -extfile "$CERT_CNF" -extensions v3_req

cat "$CERT_CRT" "$CA_CERT" >"$CERT_BUNDLE"

echo "🌐 Generating NGINX vhosts..."
for rawdir in "$WEB_ROOT"/*/; do
  [[ ! -d "$rawdir" ]] && continue
  dir="${rawdir%/}"
  site=$(basename "$dir")
  domain="$site.test"

  # Determine document root
  if [[ -f "$dir/public/index.php" ]]; then
    root_path="$dir/public"
  else
    root_path="$dir"
  fi

  # Detect PHP version
  composer_file="$dir/composer.json"
  php_ver=$(jq -r '.require.php // empty' "$composer_file" 2>/dev/null |
    grep -o "[0-9]\+\.[0-9]\+" | head -n1)
  php_ver=${php_ver:-8.2}
  php_socket="php${php_ver}-fpm.sock"

  # Write vhost, expand Bash vars; escape Nginx vars
  sudo tee "$NGINX_SITES_AVAILABLE/$domain" >/dev/null <<NGINX
server {
    listen 80;
    server_name $domain;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $domain;

    ssl_certificate     $CERT_BUNDLE;
    ssl_certificate_key $CERT_KEY;

    root $root_path;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/$php_socket;
    }

    location ~ /\.ht {
        deny all;
    }
}
NGINX

   # Enable site
  sudo ln -sf "$NGINX_SITES_AVAILABLE/$domain" "$NGINX_SITES_ENABLED/$domain"
  entry="127.0.0.1 $domain"
  if ! grep -Fxq "$entry" "$HOSTS_FILE"; then
    if echo "$entry" | sudo tee -a "$HOSTS_FILE" >/dev/null; then
      echo "Added $domain to $HOSTS_FILE"
    else
      echo "⚠️ Unable to modify Windows hosts file directly."
      echo "Launching Notepad as Admin (or open WSL in admin mode to modify $HOSTS_FILE):"
      powershell.exe -Command "Start-Process notepad.exe -ArgumentList '$WIN_HOSTS_FILE' -Verb runAs"
      echo "Please add the line manually, then save and close Notepad."
    fi
  fi
done

if sudo test -w "$HOSTS_FILE"; then
  echo "🧹 Cleaning up old vhosts..."
  for conf in "$NGINX_SITES_AVAILABLE"/*.test; do
    domain=$(basename "$conf")
    site=${domain%.test}
    if [[ ! -d "$WEB_ROOT/$site" ]]; then
      echo "🗑️ Removing $domain"
      sudo rm -f "$NGINX_SITES_AVAILABLE/$domain" "$NGINX_SITES_ENABLED/$domain"
      sudo sed -i "/$domain/d" "$HOSTS_FILE" && \
          echo "Removed $domain from $HOSTS_FILE"
    fi
  done
else
  echo "⚠️ Skipping cleanup of old vhosts due to inability to modify $HOSTS_FILE"
fi

# Fix permissions
USER_NAME=$(whoami)
sudo chown -R "$USER_NAME":www-data "$WEB_ROOT"
sudo find "$WEB_ROOT" -type d -exec chmod 750 {} \;
sudo find "$WEB_ROOT" -type f -exec chmod 640 {} \;
for appdir in "$WEB_ROOT"/*; do
  if [[ -d "$appdir/storage" ]]; then
    echo "⚙️ Setting permissions for Laravel storage and cache in $(basename "$appdir")"
    sudo chown -R "$USER_NAME":www-data "$appdir/storage" "$appdir/bootstrap/cache"
    sudo chmod -R 775 "$appdir/storage" "$appdir/bootstrap/cache"
  fi
done
sudo chmod o+x "$HOME" "$WEB_ROOT"

# Reload Nginx
if systemctl is-active --quiet nginx; then
  sudo systemctl reload nginx
else
  sudo systemctl start nginx
fi

echo "🎉 SSL Manager complete."
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
echo "You may need to restart your browser for the new SSL certificate to take effect."
echo "Also you need to install the certificate on your Windows host. See the README for instructions."
