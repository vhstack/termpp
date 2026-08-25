# termpp — „Der Prompt lebt“ (Hero-GIF)
# Git-Farbzyklus: sauber → geändert → staged → committed+ahead → Fehler → Erfolg → Laufzeit.

Output prompt.gif

Set Width 1000
Set Height 560
Set Framerate 15
Set FontSize 15
Set Padding 16
Set FontFamily "CaskaydiaCove Nerd Font Mono"
Set Theme "Catppuccin Mocha"
Set Shell bash
Set TypingSpeed 55ms

# ── Setup (unsichtbar): stacktop-Repo im Demo-HOME, Remote für den ahead-Marker ──
Hide
Type "SP=${VHS_DEMO_DIR:-$HOME/.cache/vhstack-demo}; FH=$SP/fakehome"
Enter
Type "R=$FH/projekte/stacktop; rm -rf $R $SP/stacktop-remote.git; mkdir -p $FH/projekte"
Enter
Type "cp -r ${VHS_APP_DIR:-$HOME/projekte/stacktop} $R; rm -rf $R/build $R/Debug $R/stacktop"
Enter
Type "git -C $R init -qb main && git -C $R config user.name vh && git -C $R config user.email vh@stack"
Enter
Type "git -C $R add -A && git -C $R commit -qm 'stacktop: Grundgeruest' && git -C $R config core.pager cat"
Enter
Type "git init -q --bare $SP/stacktop-remote.git && git -C $R remote add origin $SP/stacktop-remote.git && git -C $R push -qu origin main 2>/dev/null"
Enter
Type "exec $SP/stackshell $FH"
Enter
Sleep 2s
Type "clear"
Enter
Sleep 500ms
Show

# ── Szene 1: cd ins Repo → grünes Git-Segment ──
Sleep 1.5s
Type "cd projekte/stacktop"
Sleep 400ms
Enter
Sleep 2.5s

# ── Szene 2: Datei ändern → Gelb ──
Type "echo '// Schwellwerte pruefen' >> src/dashboard.cpp"
Sleep 400ms
Enter
Sleep 2.5s

# ── Szene 3: stagen, committen → Grün + ahead-Marker ──
Type "git add src/dashboard.cpp"
Sleep 400ms
Enter
Sleep 2.5s
Type "git commit -m 'dashboard: Schwellwerte angepasst'"
Sleep 400ms
Enter
Sleep 3s

# ── Szene 4: Fehler → rotes ❯, Erfolg → Grün ──
Type "false"
Sleep 400ms
Enter
Sleep 2.5s
Type "git log --oneline -2"
Sleep 400ms
Enter
Sleep 2.5s

# ── Szene 5: sleep 3 → Ausführungszeit-Segment ──
Type "sleep 3"
Sleep 400ms
Enter
Sleep 3.4s
Sleep 3s
