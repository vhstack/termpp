#!/usr/bin/env bash

set -e

# 1. Installiere Oh My Posh, falls noch nicht vorhanden
if ! command -v oh-my-posh &> /dev/null; then
  echo "Install Oh My Posh..."
  mkdir -p ~/.local/bin
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
fi

# 2. Lade das Theme nach ~/.config/ohmyposh
mkdir -p ~/.config/ohmyposh
curl -sL https://raw.githubusercontent.com/vhstack/termpp/main/vhstack.omp.json \
  -o ~/.config/ohmyposh/vhstack.omp.json

# 3. Erkenne Shell und wähle passende Konfigurationsdatei
SHELL_NAME=$(basename "$SHELL")
if [ "$SHELL_NAME" = "zsh" ]; then
  RC_FILE=~/.zshrc
elif [ "$SHELL_NAME" = "bash" ]; then
  RC_FILE=~/.bashrc
else
  echo "⚠️  Unsupported shell: $SHELL_NAME – please configure manually."
  exit 1
fi

# 4. Prüfe, ob bereits irgendein oh-my-posh-Eintrag existiert
if grep -q "oh-my-posh init" "$RC_FILE"; then
  echo "ℹ️  An oh-my-posh init call was already found in $RC_FILE. Please adjust your configuration manually."
  exit 0
fi

# 5. Füge die eval-Zeile nur hinzu, wenn sie noch nicht existiert
INIT_LINE='eval "$(~/.local/bin/oh-my-posh init '"$SHELL_NAME"' --config ~/.config/ohmyposh/vhstack.omp.json)"'

# 6. Konfiguriere vhstack-Theme
if ! grep -Fxq "$INIT_LINE" "$RC_FILE"; then
  echo "" >> "$RC_FILE"
  echo "# oh-my-posh vhstack/termpp theme" >> "$RC_FILE"
  echo "$INIT_LINE" >> "$RC_FILE"
  echo "✅ Oh My Posh init line has been added to $RC_FILE."
else
  echo "ℹ️  Init line already present in $RC_FILE."
fi

echo "🚀 All done! Start a new $SHELL_NAME session or run 'source $RC_FILE'."
