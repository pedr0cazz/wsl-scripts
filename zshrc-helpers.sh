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
  # if there’s a composer.json in cwd, pick the right PHP and invoke the real composer
  if [[ -f composer.json ]]; then
    # read the version (e.g. "8.2") from composer.json
    local php_version
    php_version=$(jq -r '.require.php // ""' composer.json |
      grep -oP '\d+\.\d+' | head -n1)
    # fall back to the default php if none in composer.json
    local php_bin
    if [[ -n $php_version && -x $(command -v php"$php_version") ]]; then
      php_bin=$(command -v php"$php_version")
    else
      php_bin=$(command -v php)
    fi

    # find the real composer executable
    local comp_bin
    comp_bin=$(command -v composer)

    echo "🚀 Running Composer with PHP ${php_bin##*/}"
    COMPOSER_ALLOW_SUPERUSER=1 "$php_bin" "$comp_bin" "$@"
    return
  fi

  # otherwise just run the system composer
  command composer "$@"
}

# ── Start ssh-agent if not running ───────────────────────────────────
if [[ -z "$SSH_AUTH_SOCK" ]]; then
  eval "$(ssh-agent -s >/dev/null 2>&1)"
  if [[ -f "$HOME/.ssh/id_rsa" ]]; then
    ssh-add "$HOME/.ssh/id_rsa" >/dev/null 2>&1
  fi
fi
