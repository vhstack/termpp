#!/usr/bin/env bash
#
# install-vhstack.sh — Full install of the vhstack terminal environment
#
# Installs in one go:
#   1. Oh My Posh prompt with the vhstack theme   (vhstack/termpp)
#   2. Tmux configuration incl. TPM and plugins   (vhstack/tmuxpp)
#   3. Neovim C/C++ configuration                 (vhstack/nvimpp)
#   4. xssh helper script (SSH into a Xephyr X-screen, see README)
#
# Existing configurations are moved to a timestamped backup directory
# (~/.vhstack-backup-<timestamp>) before anything is overwritten.
#
# Quick install (bash or zsh):
#
#   curl -sL https://raw.githubusercontent.com/vhstack/termpp/main/install-vhstack.sh | bash
#
# Requirements: git, curl — tmux and nvim should be installed, e.g.:
#
#   sudo apt install tmux neovim ripgrep clangd   # Debian/Ubuntu
#   brew install tmux neovim ripgrep llvm         # macOS
#
# After the installation start a new shell session (or `source ~/.bashrc`),
# then run `tmux` and `nvim` once so the plugins finish their setup.

set -euo pipefail

BACKUP_DIR="$HOME/.vhstack-backup-$(date +%Y%m%d-%H%M%S)"

info()  { echo "ℹ️  $*"; }
ok()    { echo "✅ $*"; }
warn()  { echo "⚠️  $*"; }
step()  { echo; echo "==> $*"; }

# Move an existing file/directory/symlink into the backup directory,
# mirroring its path relative to $HOME (avoids name collisions like
# ~/.config/nvim vs. ~/.local/share/nvim).
backup() {
  local path="$1"
  [ -e "$path" ] || [ -L "$path" ] || return 0
  local rel="${path#"$HOME"/}"
  mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
  mv "$path" "$BACKUP_DIR/$rel"
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

for tool in tmux nvim; do
  if ! command -v "$tool" &> /dev/null; then
    warn "'$tool' is not installed. The configuration will be set up anyway"
    warn "and becomes active once you install it (e.g. sudo apt install $tool)."
  fi
done
ok "Tool check done."

# --- 1. Prompt: Oh My Posh + vhstack theme (termpp) -------------------------

step "Installing Oh My Posh prompt (vhstack/termpp)"

if ! command -v oh-my-posh &> /dev/null && [ ! -x "$HOME/.local/bin/oh-my-posh" ]; then
  info "Installing Oh My Posh to ~/.local/bin ..."
  mkdir -p "$HOME/.local/bin"
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
fi

mkdir -p "$HOME/.config/ohmyposh"
backup "$HOME/.config/ohmyposh/vhstack.omp.json"
curl -sL https://raw.githubusercontent.com/vhstack/termpp/main/vhstack.omp.json \
  -o "$HOME/.config/ohmyposh/vhstack.omp.json"
ok "Theme installed: ~/.config/ohmyposh/vhstack.omp.json"

# Detect shell and pick the matching rc file
SHELL_NAME=$(basename "${SHELL:-bash}")
case "$SHELL_NAME" in
  zsh)  RC_FILE="$HOME/.zshrc" ;;
  bash) RC_FILE="$HOME/.bashrc" ;;
  *)    warn "Unsupported shell: $SHELL_NAME — configuring for bash instead."
        SHELL_NAME=bash
        RC_FILE="$HOME/.bashrc" ;;
esac
touch "$RC_FILE"

# Keep a copy of the rc file before modifying it
mkdir -p "$BACKUP_DIR"
cp "$RC_FILE" "$BACKUP_DIR/$(basename "$RC_FILE")"
info "Backed up $RC_FILE -> $BACKUP_DIR/$(basename "$RC_FILE")"

# True color support
if ! grep -q "TERM=xterm-256color" "$RC_FILE"; then
  {
    echo ""
    echo "# vhstack: true color support"
    echo "export TERM=xterm-256color"
  } >> "$RC_FILE"
  ok "TERM=xterm-256color added to $RC_FILE."
fi

# Prompt init line
if grep -q "oh-my-posh init" "$RC_FILE"; then
  info "An oh-my-posh init call already exists in $RC_FILE — leaving it untouched."
else
  {
    echo ""
    echo "# oh-my-posh vhstack/termpp theme"
    echo 'eval "$('"$HOME"'/.local/bin/oh-my-posh init '"$SHELL_NAME"' --config ~/.config/ohmyposh/vhstack.omp.json)"'
  } >> "$RC_FILE"
  ok "Oh My Posh init line added to $RC_FILE."
fi

# --- 2. Tmux configuration (tmuxpp) ------------------------------------------

step "Installing Tmux configuration (vhstack/tmuxpp)"

backup "$HOME/.tmux.conf"
backup "$HOME/.tmux"

git clone --depth 1 https://github.com/vhstack/tmuxpp.git "$HOME/.tmux"
rm -rf "$HOME/.tmux/.git" "$HOME/.tmux/assets" "$HOME/.tmux"/README*.md
ln -s "$HOME/.tmux/tmux.conf" "$HOME/.tmux.conf"
ok "Tmux configuration installed: ~/.tmux (~/.tmux.conf)"

info "Installing TPM (Tmux Plugin Manager) ..."
git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
rm -rf "$HOME/.tmux/plugins/tpm/.git"

if command -v tmux &> /dev/null; then
  info "Installing tmux plugins ..."
  "$HOME/.tmux/plugins/tpm/bin/install_plugins" > /dev/null 2>&1 || true
  # TPM reports a failure for the (already present) tpm dir itself,
  # so verify success by checking that plugins actually got installed.
  if find "$HOME/.tmux/plugins" -mindepth 1 -maxdepth 1 -type d ! -name tpm | grep -q .; then
    ok "Tmux plugins installed."
  else
    warn "Automatic plugin install failed — start tmux and press Prefix + I."
  fi
else
  warn "tmux not found — after installing it, start tmux and press Prefix + I."
fi

# --- 3. Neovim configuration (nvimpp) ----------------------------------------

step "Installing Neovim configuration (vhstack/nvimpp)"

backup "$HOME/.config/nvim"
# Move old plugin/runtime state aside for a clean start
backup "$HOME/.local/share/nvim"
backup "$HOME/.local/state/nvim"
backup "$HOME/.cache/nvim"

git clone --depth 1 https://github.com/vhstack/nvimpp "$HOME/.config/nvim"
rm -rf "$HOME/.config/nvim/.git" "$HOME/.config/nvim/assets" "$HOME/.config/nvim"/README*.md
ok "Neovim configuration installed: ~/.config/nvim"

if command -v nvim &> /dev/null; then
  info "Synchronizing Neovim plugins (headless, this may take a moment) ..."
  if nvim --headless "+Lazy! sync" +qa > /dev/null 2>&1; then
    ok "Neovim plugins synchronized."
  else
    warn "Plugin sync failed — plugins will be installed on the first nvim start."
  fi
else
  warn "nvim not found — plugins will be installed on the first nvim start."
fi

# --- 4. xssh: SSH with X11 forwarding into a Xephyr screen --------------------

step "Installing xssh script (X11 via Xephyr, vhstack/termpp)"

mkdir -p "$HOME/.local/bin"
backup "$HOME/.local/bin/xssh"
curl -sL https://raw.githubusercontent.com/vhstack/termpp/main/xssh \
  -o "$HOME/.local/bin/xssh"
chmod +x "$HOME/.local/bin/xssh"
ok "xssh installed: ~/.local/bin/xssh"

if ! command -v Xephyr &> /dev/null || ! command -v xdpyinfo &> /dev/null; then
  warn "Xephyr/x11-utils not found — xssh needs them at runtime:"
  warn "  sudo apt install xserver-xephyr openbox x11-utils"
fi

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) warn "~/.local/bin is not in your PATH — add it to $RC_FILE to call xssh directly." ;;
esac

# --- Summary ------------------------------------------------------------------

echo
echo "══════════════════════════════════════════════════════════════"
ok "vhstack environment installed!"
if [ -d "$BACKUP_DIR" ]; then
  info "Previous configuration saved in: $BACKUP_DIR"
fi
echo
echo "Next steps:"
echo "  1. Start a new $SHELL_NAME session (or run: source $RC_FILE)"
echo "  2. Run 'tmux'  — plugins: Prefix + I (Prefix = Ctrl+A) if needed"
echo "  3. Run 'nvim'  — then ':MasonInstall clangd cmake-language-server' for C/C++ LSP"
echo
echo "🚀 Happy hacking!"
