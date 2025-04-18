#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# WSL Web‑Dev Installer v4: fully quiet, resumable, with rollback on error
# -----------------------------------------------------------------------------

# 0) Cache sudo credentials upfront
echo "🔒 Caching sudo credentials..."
sudo -v
(while true; do
    sudo -n true
    sleep 60
done) &

# --- On any error, reset state and exit ---
trap 'echo "⚠ Error encountered, resetting state..."; rm -f "${STATE_FILE:-$HOME/.wsl_setup_state}"; exit 1' ERR

# 1) State tracking
default_state="$HOME/.wsl_setup_state"
read -rp "State file path [default: $default_state]: " STATE_FILE
STATE_FILE=${STATE_FILE:-"$default_state"}
LAST_DONE=0
if [[ -f "$STATE_FILE" ]]; then
    LAST_DONE=$(<"$STATE_FILE")
fi

done_step() {
    echo "$1" >"$STATE_FILE"
}

echo
# 2) Configuration prompts
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

# 3) Persist config for helper scripts
cat >~/.wsl_env <<EOF
export WEB_ROOT="$WEB_ROOT"
export SSL_DIR="$SSL_DIR"
export SCRIPTS_DIR="$SCRIPTS_DIR"
export SSL_SCRIPT="\$SCRIPTS_DIR/ssl-manager.sh"
EOF

# 4) Quiet runner: captures stderr, silences stdout
run() {
    local msg="$1"
    shift
    printf "→ %s... " "$msg"
    local output status
    output=$({ "$@" 1>/dev/null; } 2>&1) || status=$?
    if [[ -n "${status:-}" && ${status} -ne 0 ]]; then
        echo "✖"
        echo "${output}"
        exit "$status"
    else
        echo "✔"
    fi
}

# 5) Step 1: Create project root
if ((LAST_DONE < 1)); then
    run "Create project root at $WEB_ROOT" mkdir -p "$WEB_ROOT"
    done_step 1
fi

# 6) Step 2: System update & upgrade
if ((LAST_DONE < 2)); then
    run "System update & upgrade" bash -c 'sudo apt-get update -qq && sudo apt-get upgrade -qq'
    done_step 2
fi

# 7) Step 3: Install essentials
if ((LAST_DONE < 3)); then
    run "Install essentials" sudo apt-get install -y -qq build-essential curl git unzip jq nginx mysql-server redis-server php-redis
    done_step 3
fi

# 8) Step 4: Zsh & Oh My Zsh + plugins
if ((LAST_DONE < 4)); then
    run "Install Zsh" sudo apt-get install -y -qq zsh
    run "Install Oh My Zsh" bash -c 'RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    run "Clone zsh-autosuggestions" git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    run "Clone zsh-syntax-highlighting" git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    run "Clone powerlevel10k theme" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    # We avoid interactive chsh; instead we'll auto-launch zsh at the end via bashrc
    done_step 4
fi

# 9) Step 5: Configure ~/.zshrc
if ((LAST_DONE < 5)); then
    echo "→ Configuring ~/.zshrc"
    touch ~/.zshrc
    # Set ZSH theme (idempotent)
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc || true
    # Add plugins if missing
    run "Add Zsh plugins" bash -c 'grep -q "plugins=(git zsh-autosuggestions zsh-syntax-highlighting" ~/.zshrc || sed -i "s/^plugins=(/plugins=(git zsh-autosuggestions zsh-syntax-highlighting /" ~/.zshrc'
    #   # Source powerlevel10k config if p10k created
    #   run "Source p10k config" bash -c 'grep -q "source ~/.p10k.zsh" ~/.zshrc || echo "[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh" >> ~/.zshrc'
    # Add Composer global bin to PATH
    run "Add composer to PATH" bash -c 'grep -q "composer/vendor/bin" ~/.zshrc || echo "export PATH=\"$HOME/.config/composer/vendor/bin:$PATH\"" >> ~/.zshrc'
    # Source our env and helpers
    run "Source env file" bash -c 'grep -q "source ~/.wsl_env" ~/.zshrc || echo "source ~/.wsl_env" >> ~/.zshrc'
    run "Source zshrc helpers" bash -c 'grep -q "zshrc-helpers.sh" ~/.zshrc || echo "source \"$SCRIPTS_DIR/zshrc-helpers.sh\"" >> ~/.zshrc'
    done_step 5
fi

# 10) Step 6: NVM & Node.js LTS
if ((LAST_DONE < 6)); then
    run "Install NVM" git clone --depth=1 https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
    run "Install Node.js LTS" bash -c '. "$HOME/.nvm/nvm.sh" >/dev/null 2>&1 && nvm install --lts >/dev/null 2>&1'
    done_step 6
fi

# 11) Step 7: PHP versions & Composer
if ((LAST_DONE < 7)); then
    run "Add PHP PPA" sudo add-apt-repository -y ppa:ondrej/php
    run "Install PHP 8.x" bash -c 'sudo apt-get update -qq && for v in 8.2 8.3 8.4; do sudo apt-get install -y -qq php${v} php${v}-fpm php${v}-cli php${v}-common php${v}-curl php${v}-mbstring php${v}-xml php${v}-mysql php${v}-opcache php${v}-intl php${v}-zip; done'
    run "Install Composer" bash -c 'curl -sS https://getcomposer.org/installer | php -- --quiet >/dev/null 2>&1 && sudo mv composer.phar /usr/local/bin/composer'
    done_step 7
fi

# 12) Step 8: Secure MySQL root
if ((LAST_DONE < 8)); then
    run "Secure MySQL root" bash -c "sudo mysql -e \"ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY ''; FLUSH PRIVILEGES;\""
    done_step 8
fi

# 13) Step 9: Clone helper scripts
if ((LAST_DONE < 9)); then
    run "Clone helper scripts" git clone --depth=1 "$SCRIPTS_REPO" "$SCRIPTS_DIR"
    run "Make SSL manager executable" chmod +x "$SCRIPTS_DIR/ssl-manager.sh"
    done_step 9
fi

# 14) Step 10: Create SSL directory
if ((LAST_DONE < 10)); then
    run "Create SSL directory" mkdir -p "$SSL_DIR"
    done_step 10
fi

# 15) Final: completion message
if ((LAST_DONE < 11)); then
    echo
    echo "🎉 All steps complete! Please restart your terminal or run 'source ~/.zshrc'"
    # Ensure new shells auto-launch zsh
    if ! grep -q 'exec zsh -l' ~/.bashrc; then
        echo 'exec zsh -l' >>~/.bashrc
    fi
    # Start zsh right now
    exec zsh -l
    done_step 11
fi
