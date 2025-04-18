#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Main WSL Web‑Dev Installer: clones helper repo, sets up environment & config
# -----------------------------------------------------------------------------

echo "🔒 Caching sudo credentials..."
sudo -v
( while true; do sudo -n true; sleep 60; done ) &

# ——— Prompt for configuration —————————————————————————————————————————
default_state="$HOME/.wsl_setup_state"
read -rp "State file path [default: $default_state]: " STATE_FILE
STATE_FILE=${STATE_FILE:-"$default_state"}

default_web="$HOME/www"
read -rp "Project root directory [default: $default_web]: " WEB_ROOT
WEB_ROOT=${WEB_ROOT:-"$default_web"}

default_ssl="$HOME/ssl"
read -rp "SSL certificate directory [default: $default_ssl]: " SSL_DIR
SSL_DIR=${SSL_DIR:-"$default_ssl"}

default_repo="https://github.com/pedr0cazz/wsl-scripts.git"
read -rp "Scripts Git repo URL [default: $default_repo]: " SCRIPTS_REPO
SCRIPTS_REPO=${SCRIPTS_REPO:-"$default_repo"}

default_dir="$HOME/.wsl_scripts"
read -rp "Local path for cloned scripts [default: $default_dir]: " SCRIPTS_DIR
SCRIPTS_DIR=${SCRIPTS_DIR:-"$default_dir"}

# Persist config for helpers
cat > ~/.wsl_env <<EOF
export WEB_ROOT="$WEB_ROOT"
export SSL_DIR="$SSL_DIR"
export SCRIPTS_DIR="$SCRIPTS_DIR"
export SSL_SCRIPT="\$SCRIPTS_DIR/ssl-manager.sh"
EOF

LOG_FILE="${STATE_FILE}.log"
LAST_DONE=0
TOTAL_STEPS=10

# Spinner helper
tspinner(){ local pid=$1 delay=0.1 spinstr='|/-\\'; while ps -p "$pid" &>/dev/null; do printf "\r [%c] " "${spinstr:0:1}"; spinstr="${spinstr:1}${spinstr:0:1}"; sleep "$delay"; done; printf "\r"; }
# Run step wrapper
run_step(){ local msg="$1"; shift; printf "%-40s" "$msg..."; ("$@" >"$LOG_FILE" 2>&1) & tspinner $!; echo "✔"; }

# Resume logic
[[ -f "$STATE_FILE" ]] && LAST_DONE=$(<"$STATE_FILE")

for STEP in $(seq 1 $TOTAL_STEPS); do
  if (( STEP <= LAST_DONE )); then echo "✅ Step $STEP skipped"; continue; fi
  echo -e "\n⏭ Step $STEP of $TOTAL_STEPS"
  case $STEP in
    1)
      run_step "System update" bash -c 'sudo apt-get update -qq >"$LOG_FILE" 2>&1 && sudo apt-get upgrade -qq >"$LOG_FILE" 2>&1'
      ;;
    2)
      run_step "Install essentials" bash -c 'sudo apt-get install -y -qq build-essential curl git unzip jq nginx mysql-server redis-server php-redis'
      ;;
    3)
      run_step "Install Zsh & Oh My Zsh" bash -c 'sudo apt-get install -y -qq zsh && export RUNZSH=no CHSH=no && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
      run_step "Clone Zsh plugins" bash -c 'ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}; git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions; git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting; git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k'
      ;;
    4)
      run_step "Install NVM & Node.js" bash -c 'export NVM_DIR=$HOME/.nvm; git clone --depth=1 https://github.com/nvm-sh/nvm.git "$NVM_DIR"; . "$NVM_DIR/nvm.sh"; nvm install --lts'
      ;;
    5)
      run_step "Add PHP PPA & install PHP" bash -c 'sudo add-apt-repository -y ppa:ondrej/php >/dev/null 2>&1 || true; sudo apt-get update -qq; for v in 8.2 8.3 8.4; do sudo apt-get install -y -qq php${v} php${v}-fpm php${v}-cli php${v}-common php${v}-curl php${v}-gd php${v}-mbstring php${v}-xml php${v}-mysql php${v}-opcache php${v}-intl php${v}-zip php${v}-imap php${v}-pgsql php${v}-soap; done'
      ;;
    6)
      run_step "Secure MySQL root" bash -c 'sudo mysql -e "ALTER USER \'root\'@\'localhost\' IDENTIFIED WITH mysql_native_password BY ''; FLUSH PRIVILEGES;"'
      ;;
    7)
      run_step "Install Composer" bash -c 'php -r "copy(\"https://getcomposer.org/installer\",\"composer-setup.php\");" && HASH_EXPECTED="dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6" && php -r "if (hash_file(\"sha384\",\"composer-setup.php\") === \"$HASH_EXPECTED\") echo; else { unlink(\"composer-setup.php\"); exit 1; }" && php composer-setup.php && php -r "unlink(\"composer-setup.php\");" && sudo mv composer.phar /usr/local/bin/composer'
      ;;
    8)
      run_step "Clone helper scripts" bash -c 'git clone --depth=1 "$SCRIPTS_REPO" "$SCRIPTS_DIR"'
      ;;
    9)
      run_step "Install SSL Manager script" bash -c 'cp "$SCRIPTS_DIR/ssl-manager.sh" "$SSL_DIR/ssl-manager.sh" && chmod +x "$SSL_DIR/ssl-manager.sh"'
      ;;
    10)
      touch ~/.zshrc
      # ensure zshrc-helpers script exists before appending
touch "$SCRIPTS_DIR/zshrc-helpers.sh"
      run_step "Append zshrc helpers" bash -c 'grep -q "# ── Laragon SSL Manager Check" ~/.zshrc || (cat "$SCRIPTS_DIR/zshrc-helpers.sh" >> ~/.zshrc)'
      ;;
  esac
  echo "$STEP" > "$STATE_FILE"
done

echo -e "\n🎉 Setup complete! Please restart your shell or run:\n  source ~/.zshrc"
