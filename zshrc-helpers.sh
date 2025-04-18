# ── Laragon SSL Manager Check (quiet in VSCode) ──────────────────────
if [[ -n $PS1 && $TERM_PROGRAM != "vscode" ]]; then
  PROJECT_DIR="${WEB_ROOT:-$HOME/www}"
  HASH_FILE="$HOME/.laragon-projects.hash"

  # Compute hash of project folders
  CURRENT_HASH=$(find "$PROJECT_DIR" -mindepth 1 -maxdepth 1 -type d ! -name 'home' -printf '%f\n' | sort | sha256sum)

  if [[ ! -f "$HASH_FILE" || "$CURRENT_HASH" != "$(cat "$HASH_FILE")" ]]; then
    echo "🔄 Detected changes in project folders. Running SSL manager..."
    "${SSL_SCRIPT:-$HOME/.wsl_scripts/ssl-manager.sh}"
    echo "$CURRENT_HASH" >"$HASH_FILE"
  fi
fi

# ── Add Composer Global Binaries to PATH ─────────────────────────────
export PATH="$HOME/.config/composer/vendor/bin:$PATH"
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet


# ── Smart Composer PHP Version Wrapper ───────────────────────────────
composer() {
  # If there’s a composer.json, pick the right PHP and invoke the real composer
  if [[ -f composer.json ]]; then
    # Extract PHP version (e.g. "8.2") from composer.json
    local php_version
    php_version=$(jq -r '.require.php // ""' composer.json | grep -oP '\d+\.\d+' | head -n1)
    
    # Determine PHP binary
    local php_bin
    if [[ -n $php_version && -x $(command -v php"$php_version") ]]; then
      php_bin=$(command -v php"$php_version")
    else
      php_bin=$(command -v php)
    fi

    # Locate the actual composer executable (ignore this function)
    local comp_bin
    if [[ -n $(whence -p composer 2>/dev/null) ]]; then
      comp_bin=$(whence -p composer)
    else
      comp_bin=$(command -v composer)
    fi

    echo "🚀 Running Composer with PHP ${php_bin##*/}"
    COMPOSER_ALLOW_SUPERUSER=1 "$php_bin" "$comp_bin" "$@"
    return
  fi

  # Otherwise just call the system composer directly
  command composer "$@"
}

# ── Start ssh-agent if not running ───────────────────────────────────
if [[ -z "$SSH_AUTH_SOCK" ]]; then
  eval "$(ssh-agent -s >/dev/null 2>&1)"
  if [[ -f "$HOME/.ssh/id_rsa" ]]; then
    ssh-add "$HOME/.ssh/id_rsa" >/dev/null 2>&1
  fi
fi
