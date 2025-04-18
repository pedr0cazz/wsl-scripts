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

LOG_FILE="${STATE_FILE}.log"
LAST_DONE=0
TOTAL_STEPS=10

# Spinner helper
tspinner(){ local pid=$1 delay=0.1 spin='|/-\\'; while ps -p "$pid" &>/dev/null; do printf "\r [%c] " "${spin:0:1}"; spin="${spin:1}${spin:0:1}"; sleep "$delay"; done; printf "\r"; }
# Step runner
run_step(){ local msg="$1"; shift; printf "%-40s" "$msg..."; ("$@" >"$LOG_FILE" 2>&1) & tspinner $!; echo "✔"; }

# Resume progress
[[ -f "$STATE_FILE" ]] && LAST_DONE=$(<"$STATE_FILE")

for STEP in $(seq 1 $TOTAL_STEPS); do
  if (( STEP <= LAST_DONE )); then echo "✅ Step $STEP skipped"; continue; fi
  echo -e "\n⏭ Step $STEP of $TOTAL_STEPS"
  case $STEP in
    1) run_step "System update" sudo apt-get update -qq && sudo apt-get upgrade -qq ;;  
    2) run_step "Install essentials" sudo apt-get install -y -qq build-essential curl git unzip jq nginx mysql-server redis-server php-redis ;;  
    3)
       run_step "Install Zsh & Oh My Zsh" bash -c 'sudo apt-get install -y -qq zsh && export RUNZSH=no CHSH=no && sh -c "\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
       run_step "Clone Zsh plugins" bash -c 'ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}; git clone -q https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions; git clone -q https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting; git clone -q https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k'
       ;;  
    4) run_step "Install NVM & Node.js" bash -c 'export NVM_DIR=$HOME/.nvm; git clone -q https://github.com/nvm-sh/nvm.git "$NVM_DIR"; . "$NVM_DIR/nvm.sh"; nvm install --lts' ;;  
    5) run_step "Add PHP PPA & install PHP" bash -c 'sudo add-apt-repository -y ppa:ondrej/php >/dev/null 2>&1 || true; sudo apt-get update -qq; for v in 8.2 8.3 8.4; do sudo apt-get install -y -qq php${v} php${v}-fpm php${v}-cli; done' ;;  
    6) run_step "Secure MySQL root" sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY ''; FLUSH PRIVILEGES;" ;;  
    7) run_step "Install Composer" bash -c 'php -r "copy(\"https://getcomposer.org/installer\",\"composer-setup.php\");" && php composer-setup.php && sudo mv composer.phar /usr/local/bin/composer' ;;  
    8) run_step "Clone helper scripts" git clone --depth=1 "$SCRIPTS_REPO" "$SCRIPTS_DIR" ;;  
    9) run_step "Install SSL Manager" bash -c 'cp "$SCRIPTS_DIR/ssl-manager.sh" "$SSL_DIR/ssl-manager.sh" && chmod +x "$SSL_DIR/ssl-manager.sh"' ;;  
   10) run_step "Install zshrc helpers" bash -c 'cat "$SCRIPTS_DIR/zshrc-helpers.sh" >> "$HOME/.zshrc"' ;;  
  esac
  echo "$STEP" > "$STATE_FILE"
done

echo -e "\n🎉 Setup complete! Please restart your shell or run: \n  source ~/.zshrc"
echo "🔑 Remember to add your SSH key to the ssh-agent."
echo "🗂️  Your projects are located in: $WEB_ROOT"
echo "🔒 Your SSL certificates are located in: $SSL_DIR"
echo "📜 Your scripts are located in: $SCRIPTS_DIR"
