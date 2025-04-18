#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# WSL Web‑Dev Installer v2: streamlined, resumable, and idempotent
# -----------------------------------------------------------------------------

# State tracking
default_state="$HOME/.wsl_setup_state"
read -rp "State file path [default: $default_state]: " STATE_FILE
STATE_FILE=${STATE_FILE:-"$default_state"}
LAST_DONE=0
[[ -f "$STATE_FILE" ]] && LAST_DONE=$(<"$STATE_FILE")

# Helper to record step completion
done_step(){ echo "$1" > "$STATE_FILE"; }

# Configuration prompts
default_web="$HOME/www"
read -rp "Project root directory [default: $default_web]: " WEB_ROOT
WEB_ROOT=${WEB_ROOT:-"$default_web"}

default_ssl="$HOME/ssl"
read -rp "SSL directory [default: $default_ssl]: " SSL_DIR
SSL_DIR=${SSL_DIR:-"$default_ssl"}

default_repo="https://github.com/pedr0cazz/wsl-scripts.git"
read -rp "Scripts Git repo URL [default: $default_repo]: " SCRIPTS_REPO
SCRIPTS_REPO=${SCRIPTS_REPO:-"$default_repo"}

default_dir="$HOME/.wsl_scripts"
read -rp "Local scripts path [default: $default_dir]: " SCRIPTS_DIR
SCRIPTS_DIR=${SCRIPTS_DIR:-"$default_dir"}

# Persist config for helpers
cat > ~/.wsl_env <<EOF
export WEB_ROOT="$WEB_ROOT"
export SSL_DIR="$SSL_DIR"
export SCRIPTS_DIR="$SCRIPTS_DIR"
export SSL_SCRIPT="\$SCRIPTS_DIR/ssl-manager.sh"
EOF

# Simple runner with output suppression
run(){ local msg="$1"; shift; printf "→ %s... " "$msg"; if ! "$@" &>/dev/null; then echo "✖"; exit 1; else echo "✔"; fi }

echo
# 1) Create project root
if (( LAST_DONE < 1 )); then
  run "Create project root at $WEB_ROOT" mkdir -p "$WEB_ROOT"
  done_step 1
fi

# 2) Install essentials quietly
if (( LAST_DONE < 2 )); then
  run "Update & upgrade system" sudo apt-get update -qq && sudo apt-get upgrade -qq
  run "Install essentials" sudo apt-get install -y -qq build-essential curl git unzip jq nginx mysql-server redis-server php-redis
  done_step 2
fi

# 3) Install Zsh, Oh My Zsh, plugins & set default shell
if (( LAST_DONE < 3 )); then
  run "Install Zsh" sudo apt-get install -y -qq zsh
  run "Install Oh My Zsh" sh -c "RUNZSH=no CHSH=no $(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
  run "Clone zsh-autosuggestions" git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
  run "Clone zsh-syntax-highlighting" git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
  run "Clone powerlevel10k theme" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
  run "Set Zsh as default shell" sudo chsh -s "$(which zsh)" "$USER"
  done_step 3
fi

# 4) Configure ~/.zshrc
if (( LAST_DONE < 4 )); then
  touch ~/.zshrc
  run "Set theme in .zshrc" bash -c 'grep -q "^ZSH_THEME=\"powerlevel10k/powerlevel10k\"" ~/.zshrc || sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/" ~/.zshrc'
  run "Set plugins in .zshrc" bash -c 'grep -q "zsh-autosuggestions" ~/.zshrc || sed -i "s/^plugins=(/plugins=(git zsh-autosuggestions zsh-syntax-highlighting /" ~/.zshrc'
  run "Ensure p10k sourced" bash -c 'grep -q "source ~/.p10k.zsh" ~/.zshrc || echo "[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh" >> ~/.zshrc'
  run "Append composer PATH" bash -c 'grep -q "composer/vendor/bin" ~/.zshrc || echo "export PATH=\"$HOME/.config/composer/vendor/bin:$PATH\"" >> ~/.zshrc'
  run "Source wsl_env in .zshrc" bash -c 'grep -q "source ~/.wsl_env" ~/.zshrc || echo "source ~/.wsl_env" >> ~/.zshrc'
  run "Source zshrc helpers" bash -c 'grep -q "zshrc-helpers.sh" ~/.zshrc || echo "source \"$SCRIPTS_DIR/zshrc-helpers.sh\"" >> ~/.zshrc'
  done_step 4
fi

# 5) Install NVM & Node.js LTS
if (( LAST_DONE < 5 )); then
  run "Install NVM" git clone --depth=1 https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
  run "Install Node.js LTS" bash -c '. "$HOME/.nvm/nvm.sh" && nvm install --lts'
  done_step 5
fi

# 6) Install PHP 8.2, 8.3, 8.4 and Composer
if (( LAST_DONE < 6 )); then
  run "Add PHP PPA" sudo add-apt-repository -y ppa:ondrej/php
  run "Install PHP versions" bash -c 'sudo apt-get update -qq && for v in 8.2 8.3 8.4; do sudo apt-get install -y -qq php${v} php${v}-fpm php${v}-cli php${v}-common php${v}-curl php${v}-gd php${v}-mbstring php${v}-xml php${v}-mysql php${v}-opcache php${v}-intl php${v}-zip; done'
  run "Install Composer" bash -c 'curl -sS https://getcomposer.org/installer | php -- --quiet && sudo mv composer.phar /usr/local/bin/composer'
  done_step 6
fi

# 7) Secure MySQL root
if (( LAST_DONE < 7 )); then
  run "Secure MySQL root" sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY ''; FLUSH PRIVILEGES;"
  done_step 7
fi

# 8) Clone helper scripts and make executable
if (( LAST_DONE < 8 )); then
  run "Clone helper scripts" git clone --depth=1 "$SCRIPTS_REPO" "$SCRIPTS_DIR"
  run "Make SSL manager executable" chmod +x "$SCRIPTS_DIR/ssl-manager.sh"
  done_step 8
fi

# 9) Ensure SSL directory exists
if (( LAST_DONE < 9 )); then
  run "Create SSL directory" mkdir -p "$SSL_DIR"
  done_step 9
fi

# 10) Final message
if (( LAST_DONE < 10 )); then
  echo; echo "🎉 All steps complete! Restart your terminal or run: source ~/.zshrc"; done_step 10
fi
