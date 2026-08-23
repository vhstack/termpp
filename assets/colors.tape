# termpp — Farbtiefen-Stills (True Color vs. 256-Farben-Fallback)
# Erzeugt screenshot-truecolor.png und screenshot-256color.png.
# Der 256er-Fallback entsteht echt: ein tmux ohne RGB-Terminfo quantisiert
# die 24-Bit-Sequenzen auf die 256er-Palette.

Output colors-scratch.gif

Set Width 1220
Set Height 420
Set Framerate 15
Set FontSize 15
Set Padding 16
Set FontFamily "CaskaydiaCove Nerd Font Mono"
Set Theme "Catppuccin Mocha"
Set Shell bash
Set TypingSpeed 40ms

Hide
Type "SP=${VHS_DEMO_DIR:-$HOME/.cache/vhstack-demo}; FH=$SP/fakehome"
Enter
Type "cp ${VHS_TCTEST:-../truecolor-test.sh} $FH/truecolor-test.sh; tmux -L quant kill-server 2>/dev/null"
Enter
Type "exec $SP/stackshell $FH"
Enter
Sleep 2s
Type "clear"
Enter
Sleep 500ms
Show

# ── True Color: direkt im Terminal ──
Sleep 500ms
Type "bash truecolor-test.sh"
Enter
Sleep 1.5s
Screenshot screenshot-truecolor.png
Sleep 500ms

# ── 256 Farben: im tmux ohne RGB-Fähigkeit ──
Hide
Type "clear"
Enter
Type "env -u COLORTERM tmux -L quant -f /dev/null new-session \; set -g status off"
Enter
Sleep 2s
Type "true"
Enter
Type "clear"
Enter
Sleep 500ms
Show
Sleep 500ms
Type "bash truecolor-test.sh"
Enter
Sleep 1.5s
Screenshot screenshot-256color.png
Sleep 500ms
Hide
Type "exit"
Enter
