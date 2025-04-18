#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# WSL Web‑Dev Installer: All‑in‑one setup for dev tools, Zsh, SSL & helpers
# -----------------------------------------------------------------------------

# 1) Cache sudo
echo "🔒 Caching sudo credentials..."
sudo -v
# keep-alive
( while true; do sudo -n true; sleep 60; done ) &

# 2) Prompt configuration defaults
read -rp "Project root directory [default: $HOME/www]: " WEB_ROOT
WEB_ROOT=${WEB_ROOT:-"$HOME/www"}
read -rp "SSL directory [default: $HOME/ssl]: " SSL_DIR
SSL_DIR=${SSL_DIR:-"$HOME/ssl"}
read -rp "Scripts repo URL [default: https://github.com/pedr0cazz/wsl-scripts.git]: " SCRIPTS_REPO
SCRIPTS_REPO=${SCRIPTS_REPO:-"https://github.com/pedr0cazz/wsl-scripts.git"}
read -rp "Local scripts path [default: $HOME/.wsl_scripts]: " SCRIPTS_DIR
SCRIPTS_DIR=${SCRIPTS_DIR:-"$HOME/.wsl_scripts"}

# 3) Persist config
cat > ~/.wsl_env <<EOF
export WEB_ROOT="$WEB_ROOT"
export SSL_DIR="$SSL_DIR"
export SCRIPTS_DIR="$SCRIPTS_DIR"
export SSL_SCRIPT="\$SCRIPTS_DIR/ssl-manager.sh"
EOF

# 4) Define helper
run(){
  local cmd="$*"
  printf "→ %s... " "$1"
  shift
  if ! $* &>/dev/null; then
    echo "✖"
    echo "Error running: $cmd" >&2
    exit 1
  fi
  echo "✔"
}

# Begin setup
# A) Create project root
echo; run "Create project root" mkdir -p "$WEB_ROOT"
# B) Install essentials
echo; run "Update & upgrade system" sudo apt-get update -qq && sudo apt-get upgrade -qq
run "Install essentials" sudo apt-get install -y -qq build-essential curl git unzip jq nginx mysql-server redis-server php-redis

# C) Install Zsh & Oh My Zsh
echo; run "Install Zsh" sudo apt-get install -y -qq zsh
run "Install Oh My Zsh" sh -c "RUNZSH=no CHSH=no CHSH=no $(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Ensure plugins/themes dir
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
run "Clone zsh-autosuggestions" git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
run "Clone zsh-syntax-highlighting" git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
run "Clone powerlevel10k" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# D) Configure .zshrc
ZSHRC=$HOME/.zshrc
touch "$ZSHRC"
# Theme & plugins
grep -q '^ZSH_THEME="powerlevel10k/powerlevel10k"' "$ZSHRC" || sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"
grep -q 'zsh-autosuggestions' "$ZSHRC" || sed -i 's/^plugins=(/plugins=(git zsh-autosuggestions zsh-syntax-highlighting /' "$ZSHRC"
# Source powerlevel10k config
grep -q 'source ~/.p10k.zsh' "$ZSHRC" || echo '[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh' >> "$ZSHRC"
# Append helpers
grep -q 'export PATH=.*composer' "$ZSHRC" || echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> "$ZSHRC"
# Load env and helpers
grep -q 'source ~/.wsl_env' "$ZSHRC" || echo 'source ~/.wsl_env' >> "$ZSHRC"
grep -q 'zshrc-helpers.sh' "$ZSHRC" || echo 'source "$SCRIPTS_DIR/zshrc-helpers.sh"' >> "$ZSHRC"

# E) Set default shell to zsh
run "Set default shell" sudo chsh -s $(which zsh) "$USER"

# F) Install NVM & Node.js
echo; run "Install NVM" git clone --depth=1 https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
run "Load NVM & install Node.js" bash -c '. "$HOME/.nvm/nvm.sh" && nvm install --lts'

# G) PHP & Composer
# Add Ondřej Surý’s PHP PPA
run "Add PHP PPA" sudo add-apt-repository -y ppa:ondrej/php
# Install multiple PHP versions
run "Install PHP versions" bash -c 'sudo apt-get update -qq; for v in 8.2 8.3 8.4; do sudo apt-get install -y -qq php${v} php${v}-fpm php${v}-cli php${v}-common php${v}-curl php${v}-gd php${v}-mbstring php${v}-xml php${v}-mysql php${v}-opcache php${v}-intl php${v}-zip; done'
# Install Composer
run "Install Composer" bash -c 'curl -sS https://getcomposer.org/installer | php -- --quiet && sudo mv composer.phar /usr/local/bin/composer'

# H) Secure MySQL MySQL
echo; run "Secure MySQL root" sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY ''; FLUSH PRIVILEGES;"

# I) Clone helper scripts
echo; run "Clone helper scripts" git clone --depth=1 "$SCRIPTS_REPO" "$SCRIPTS_DIR"
run "Make SSL manager executable" chmod +x "$SCRIPTS_DIR/ssl-manager.sh"

# J) Final
echo; echo "🎉 All done! Restart your terminal or run 'source ~/.zshrc' to begin."
