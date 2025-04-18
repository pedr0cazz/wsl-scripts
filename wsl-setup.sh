#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# WSL Web‑Dev Installer v3: quiet, resumable, idempotent
# -----------------------------------------------------------------------------

# ——— Cache sudo credentials upfront —————————————————————————————————————
echo "🔒 Caching sudo credentials..."
sudo -v
# Keep alive
(while true; do
    sudo -n true
    sleep 60
done) &

# ——— State tracking ———————————————————————————————————————————————
default_state="$HOME/.wsl_setup_state"
read -rp "State file path [default: $default_state]: " STATE_FILE
STATE_FILE=${STATE_FILE:-"$default_state"}
LAST_DONE=0
if [[ -f "$STATE_FILE" ]]; then
    LAST_DONE=$(<"$STATE_FILE")
fi
# Mark step done
done_step() { echo "$1" >"$STATE_FILE"; }

# ——— Configuration prompts ——————————————————————————————————————————
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

# ——— Persist config ————————————————————————————————————————————————
cat >~/.wsl_env <<EOF
export WEB_ROOT="$WEB_ROOT"
export SSL_DIR="$SSL_DIR"
export SCRIPTS_DIR="$SCRIPTS_DIR"
export SSL_SCRIPT="\$SCRIPTS_DIR/ssl-manager.sh"
EOF

# ——— Quiet runner ————————————————————————————————————————————————————
run() {
    local msg="$1"
    shift
    printf "→ %s... " "$msg"
    if ! "$@" &>/dev/null; then
        echo "✖"
        exit 1
    else echo "✔"; fi
}

echo
# 1) Create project root
if ((LAST_DONE < 1)); then
    run "Creating project root at $WEB_ROOT" mkdir -p "$WEB_ROOT"
    done_step 1
fi

# 2) Update & upgrade quietly
if ((LAST_DONE < 2)); then
    run "Updating & upgrading system" bash -c 'sudo apt-get update -qq && sudo apt-get upgrade -qq'
    done_step 2
fi

# 3) Install essentials
if ((LAST_DONE < 3)); then
    run "Installing essentials" bash -c 'sudo apt-get install -y -qq build-essential curl git unzip jq nginx mysql-server redis-server php-redis'
    done_step 3
fi

# 4) Install Zsh & Oh My Zsh + plugins
if ((LAST_DONE < 4)); then
    run "Installing Zsh" bash -c 'sudo apt-get install -y -qq zsh'
    run "Installing Oh My Zsh" bash -c 'RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
    run "Cloning zsh-autosuggestions" bash -c 'git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions'
    run "Cloning zsh-syntax-highlighting" bash -c 'git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting'
    run "Cloning powerlevel10k theme" bash -c 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k'
    run "Setting Zsh as default shell" bash -c "sudo chsh -s \"$(which zsh)\" '$USER'"
    done_step 4
fi

# 5) Configure .zshrc (always idempotent)
if ((LAST_DONE < 5)); then
    echo "→ Configuring ~/.zshrc"
    touch ~/.zshrc
    # Theme
    grep -q '^ZSH_THEME="powerlevel10k/powerlevel10k"' ~/.zshrc || sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    # Plugins
    grep -q 'zsh-autosuggestions' ~/.zshrc || sed -i 's/^plugins=(/plugins=(git zsh-autosuggestions zsh-syntax-highlighting /' ~/.zshrc
    # p10k
    grep -q 'source ~/.p10k.zsh' ~/.zshrc || echo '[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh' >>~/.zshrc
    # Composer path
    grep -q 'composer/vendor/bin' ~/.zshrc || echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >>~/.zshrc
    # Source env & helpers
    grep -q 'source ~/.wsl_env' ~/.zshrc || echo 'source ~/.wsl_env' >>~/.zshrc
    grep -q 'zshrc-helpers.sh' ~/.zshrc || echo 'source "$SCRIPTS_DIR/zshrc-helpers.sh"' >>~/.zshrc
    done_step 5
fi

# 6) Install NVM & Node.js LTS
if ((LAST_DONE < 6)); then
    run "Installing NVM" bash -c 'git clone --depth=1 https://github.com/nvm-sh/nvm.git "$HOME/.nvm"'
    run "Installing Node.js LTS" bash -c '. "$HOME/.nvm/nvm.sh" && nvm install --lts'
    done_step 6
fi

# 7) Install PHP versions & Composer
if ((LAST_DONE < 7)); then
    run "Adding PHP PPA" bash -c 'sudo add-apt-repository -y ppa:ondrej/php'
    run "Installing PHP 8.2/8.3/8.4" bash -c 'sudo apt-get update -qq && for v in 8.2 8.3 8.4; do sudo apt-get install -y -qq php${v} php${v}-fpm php${v}-cli php${v}-common php${v}-curl php${v}-mbstring php${v}-xml php${v}-mysql php${v}-opcache php${v}-intl php${v}-zip; done'
    run "Installing Composer" bash -c 'curl -sS https://getcomposer.org/installer | php -- --quiet && sudo mv composer.phar /usr/local/bin/composer'
    done_step 7
fi

# 8) Secure MySQL root user
if ((LAST_DONE < 8)); then
    run "Securing MySQL root" bash -c "sudo mysql -e \"ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY ''; FLUSH PRIVILEGES;\""
    done_step 8
fi

# 9) Clone helper scripts & ensure executable
if ((LAST_DONE < 9)); then
    run "Cloning helper scripts" bash -c 'git clone --depth=1 "$SCRIPTS_REPO" "$SCRIPTS_DIR"'
    run "Making SSL manager executable" bash -c 'chmod +x "$SCRIPTS_DIR/ssl-manager.sh"'
    done_step 9
fi

# 10) Create SSL_DIR
if ((LAST_DONE < 10)); then
    run "Creating SSL directory" bash -c 'mkdir -p "$SSL_DIR"'
    done_step 10
fi

# Completion
if ((LAST_DONE < 11)); then
    echo
    echo "🎉 Setup complete! Please restart your terminal or run 'source ~/.zshrc'."
    done_step 11
fi
