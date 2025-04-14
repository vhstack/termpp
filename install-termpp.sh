#!/usr/bin/env bash

set -e

# 1. Installiere Oh My Posh, falls noch nicht vorhanden
if ! command -v oh-my-posh &> /dev/null; then
  echo "Installiere Oh My Posh..."
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
  echo "⚠️  Nicht unterstützte Shell: $SHELL_NAME – bitte manuell konfigurieren."
  exit 1
fi

# 4. Prüfe, ob bereits irgendein oh-my-posh-Eintrag existiert
if grep -q "oh-my-posh init" "$RC_FILE"; then
  echo "ℹ️  Ein oh-my-posh init-Aufruf wurde bereits in $RC_FILE gefunden. Bitte passe deine Konfiguration manuell an."
  exit 0
fi

# 5. Füge die eval-Zeile nur hinzu, wenn sie noch nicht existiert
INIT_LINE='eval "$(~/.local/bin/oh-my-posh init '"$SHELL_NAME"' --config ~/.config/ohmyposh/vhstack.omp.json)"'

if ! grep -Fxq "$INIT_LINE" "$RC_FILE"; then
  echo "$INIT_LINE" >> "$RC_FILE"
  echo "✅ Oh My Posh Init-Zeile wurde zu $RC_FILE hinzugefügt."
else
  echo "ℹ️  Init-Zeile bereits in $RC_FILE vorhanden."
fi

echo "🚀 Fertig! Starte eine neue $SHELL_NAME-Sitzung oder führe 'source $RC_FILE' aus."

