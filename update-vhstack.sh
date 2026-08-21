#!/usr/bin/env bash
#
# update-vhstack.sh — Update an existing vhstack terminal environment
#
# Brings an installation made by install-vhstack.sh up to date:
#   1. Oh My Posh vhstack theme                    (vhstack/termpp)
#   2. Tmux configuration                          (vhstack/tmuxpp)
#   3. Neovim configuration + plugin sync          (vhstack/nvimpp)
#   4. xssh helper script                          (vhstack/termpp)
#
# Shell rc files (~/.bashrc / ~/.zshrc) are NOT touched — for a fresh
# setup use install-vhstack.sh instead. Plugin data (~/.tmux/plugins,
# ~/.local/share/nvim) is kept; only the configurations are replaced.
# The replaced configurations are copied to a timestamped backup
# directory (~/.vhstack-backup-update-<timestamp>) first, in case you
# made local changes.
#
# Quick update (bash or zsh):
#
#   curl -sL https://raw.githubusercontent.com/vhstack/termpp/main/update-vhstack.sh | bash
#
# install-vhstack.sh also installs this script as ~/.local/bin/update-vhstack,
# so after the initial install you can simply run: update-vhstack

set -euo pipefail

BACKUP_DIR="$HOME/.vhstack-backup-update-$(date +%Y%m%d-%H%M%S)"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

info()  { echo "ℹ️  $*"; }
ok()    { echo "✅ $*"; }
warn()  { echo "⚠️  $*"; }
step()  { echo; echo "==> $*"; }

# Download a file to the temp directory first and only replace the
# target on success — a failed download must never clobber a working
# file with an empty or HTML error body.
fetch() {
  local url="$1" dest="$2"
  local tmp="$TMP_DIR/fetch.$$"
  if curl -fsSL "$url" -o "$tmp"; then
    mv "$tmp" "$dest"
    return 0
  fi
  rm -f "$tmp"
  warn "Download failed: $url — keeping the existing file."
  return 1
}

# Copy an existing file/directory into the backup directory, mirroring
# its path relative to $HOME (same layout as install-vhstack.sh).
backup() {
  local path="$1"
  [ -e "$path" ] || [ -L "$path" ] || return 0
  local rel="${path#"$HOME"/}"
  mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
  cp -a "$path" "$BACKUP_DIR/$rel"
  info "Backed up $path -> $BACKUP_DIR/$rel"
}

# --- 0. Preconditions -------------------------------------------------------

step "Checking required tools"

for tool in git curl; do
  if ! command -v "$tool" &> /dev/null; then
    echo "❌ '$tool' is required but not installed. Aborting."
    exit 1
  fi
done

if [ ! -e "$HOME/.config/ohmyposh/vhstack.omp.json" ] \
   && [ ! -e "$HOME/.tmux/tmux.conf" ] \
   && [ ! -e "$HOME/.config/nvim/init.lua" ]; then
  echo "❌ No vhstack installation found — run install-vhstack.sh first:"
  echo "   curl -sL https://raw.githubusercontent.com/vhstack/termpp/main/install-vhstack.sh | bash"
  exit 1
fi
ok "Tool check done."

# --- 1. Prompt theme (termpp) -------------------------------------------------

step "Updating Oh My Posh theme (vhstack/termpp)"

if [ -e "$HOME/.config/ohmyposh/vhstack.omp.json" ]; then
  backup "$HOME/.config/ohmyposh/vhstack.omp.json"
  if fetch https://raw.githubusercontent.com/vhstack/termpp/main/vhstack.omp.json \
       "$HOME/.config/ohmyposh/vhstack.omp.json"; then
    ok "Theme updated: ~/.config/ohmyposh/vhstack.omp.json"
  fi
else
  warn "Theme not installed — skipping (run install-vhstack.sh for a full setup)."
fi

# --- 2. Tmux configuration (tmuxpp) ------------------------------------------

step "Updating Tmux configuration (vhstack/tmuxpp)"

if [ -e "$HOME/.tmux/tmux.conf" ]; then
  info "Fetching latest vhstack/tmuxpp ..."
  git clone --depth 1 --quiet https://github.com/vhstack/tmuxpp.git "$TMP_DIR/tmuxpp"
  rm -rf "$TMP_DIR/tmuxpp/.git" "$TMP_DIR/tmuxpp/assets" "$TMP_DIR/tmuxpp"/README*.md

  # Back up and replace the configuration files. ~/.tmux/plugins is kept —
  # the optional catppuccin theme lives there (manually cloned).
  for entry in "$HOME/.tmux"/* "$HOME/.tmux"/.[!.]*; do
    [ -e "$entry" ] || [ -L "$entry" ] || continue
    [ "$(basename "$entry")" = "plugins" ] && continue
    backup "$entry"
    rm -rf "$entry"
  done
  cp -a "$TMP_DIR/tmuxpp/." "$HOME/.tmux/"

  # Recreate the symlink in case it is missing or points elsewhere.
  if [ ! -L "$HOME/.tmux.conf" ] || [ "$(readlink "$HOME/.tmux.conf")" != "$HOME/.tmux/tmux.conf" ]; then
    backup "$HOME/.tmux.conf"
    rm -f "$HOME/.tmux.conf"
    ln -s "$HOME/.tmux/tmux.conf" "$HOME/.tmux.conf"
  fi
  ok "Tmux configuration updated: ~/.tmux (~/.tmux.conf)"

  if command -v tmux &> /dev/null && [ -n "${TMUX:-}" ]; then
    tmux source-file "$HOME/.tmux.conf" > /dev/null 2>&1 || true
    info "Running tmux session reloaded."
  fi
else
  warn "Tmux configuration not installed — skipping."
fi

# --- 3. Neovim configuration (nvimpp) ----------------------------------------

step "Updating Neovim configuration (vhstack/nvimpp)"

if [ -e "$HOME/.config/nvim/init.lua" ]; then
  info "Fetching latest vhstack/nvimpp ..."
  git clone --depth 1 --quiet https://github.com/vhstack/nvimpp "$TMP_DIR/nvimpp"
  rm -rf "$TMP_DIR/nvimpp/.git" "$TMP_DIR/nvimpp/assets" "$TMP_DIR/nvimpp"/README*.md

  backup "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim"
  cp -a "$TMP_DIR/nvimpp" "$HOME/.config/nvim"
  ok "Neovim configuration updated: ~/.config/nvim"

  if command -v nvim &> /dev/null; then
    info "Synchronizing Neovim plugins (headless, this may take a moment) ..."
    if nvim --headless "+Lazy! sync" +qa > /dev/null 2>&1; then
      ok "Neovim plugins synchronized."
    else
      warn "Plugin sync failed — plugins will be updated on the next nvim start."
    fi
  else
    warn "nvim not found — plugins will be updated on the next nvim start."
  fi
else
  warn "Neovim configuration not installed — skipping."
fi

# --- 4. xssh script (termpp) ---------------------------------------------------

step "Updating xssh script (vhstack/termpp)"

if [ -e "$HOME/.local/bin/xssh" ]; then
  backup "$HOME/.local/bin/xssh"
  if fetch https://raw.githubusercontent.com/vhstack/termpp/main/xssh \
       "$HOME/.local/bin/xssh"; then
    chmod +x "$HOME/.local/bin/xssh"
    ok "xssh updated: ~/.local/bin/xssh"
  fi
else
  warn "xssh not installed — skipping."
fi

# --- 5. Self-update ------------------------------------------------------------

# fetch() replaces via temp file + mv (atomic), so a possibly running
# copy of this very script is never truncated in place.
if [ -e "$HOME/.local/bin/update-vhstack" ]; then
  if fetch https://raw.githubusercontent.com/vhstack/termpp/main/update-vhstack.sh \
       "$HOME/.local/bin/update-vhstack"; then
    chmod +x "$HOME/.local/bin/update-vhstack"
  fi
fi

# --- Summary ------------------------------------------------------------------

echo
echo "══════════════════════════════════════════════════════════════"
ok "vhstack environment updated!"
if [ -d "$BACKUP_DIR" ]; then
  info "Previous configuration saved in: $BACKUP_DIR"
fi
echo
echo "Next steps:"
echo "  1. tmux: reload with Prefix + r (Prefix = Ctrl+A) or restart tmux"
echo "  2. nvim: plugins are already in sync — just keep working"
echo
echo "🚀 Happy hacking!"
