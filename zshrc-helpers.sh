# ── Laragon SSL Manager Check (quiet in VSCode) ──────────────────────
if [[ -n $PS1 && $TERM_PROGRAM != "vscode" ]]; then
  PROJECT_DIR="${WEB_ROOT:-$HOME/www}"
  HASH_FILE="$HOME/.laragon-projects.hash"

  # Compute hash of project folders
  CURRENT_HASH=$(find "$PROJECT_DIR" -mindepth 1 -maxdepth 1 -type d ! -name 'home' -printf '%f\n' | sort | sha256sum)

  if [[ ! -f "$HASH_FILE" || "$CURRENT_HASH" != "$(cat "$HASH_FILE")" ]]; then
      echo "🔄 Detected changes in project folders. Running SSL manager..."
      "${SSL_SCRIPT:-$HOME/.wsl_scripts/ssl-manager.sh}"
      echo "$CURRENT_HASH" > "$HASH_FILE"
  fi
fi

# ── Add Composer Global Binaries to PATH ─────────────────────────────
export PATH="$HOME/.config/composer/vendor/bin:$PATH"

# ── Smart Composer PHP Version Wrapper ───────────────────────────────
composer() {
  if [[ -f "composer.json" ]]; then
    local pv
    pv=$(jq -r '.require.php' composer.json | grep -o "[0-9]\+\.[0-9]\+" | head -n1)
    if [[ -n "$pv" && $(command -v php"$pv") ]]; then
      echo "🚀 Running Composer with PHP $pv"
      COMPOSER_ALLOW_SUPERUSER=1 $(command -v php"$pv") /usr/bin/composer "$@"
      return
    fi
  fi
  command composer "$@"
}

# ── Start ssh-agent if not running ───────────────────────────────────
if [[ -z "$SSH_AUTH_SOCK" ]]; then
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa
fi
