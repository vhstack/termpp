# Changelog

Dieses Projekt folgt [Semantic Versioning](https://semver.org/lang/de/).

Für eine Konfigurationssammlung gilt:

- **major** — Update braucht Handarbeit (Pfade, Keybindings, Breaking Change)
- **minor** — neue Funktionen, abwärtskompatibel
- **patch** — Fehlerbehebungen, Feinschliff

## [1.3.0] — 2026-08-24

### Hinzugefügt

- Keybinding Shift+Enter in `settings.json`: Zeilenumbruch statt Absenden
  in Eingabezeilen (`sendInput` mit ESC+CR), funktioniert unabhängig vom
  Tastatur-Protokoll des laufenden Programms
- Tastenkürzel-Tabellen in allen drei READMEs um `Shift + Enter` ergänzt

## [1.2.0] — 2026-08-22

Erstes getaggtes Release. Der Stand entspricht der bisherigen Entwicklung auf
`main` (seit 2025-04-01).

### Enthalten

- `settings.json` für Windows Terminal mit vorbereiteten Profilen und dem
  Farbschema Catppuccin Mocha
- `vhstack.omp.json` als Oh-My-Posh-Theme, abgestimmt auf nvimpp und tmuxpp
- `xssh` — SSH mit X11-Forwarding in einen Xephyr-Screen, für ältere
  X-Anwendungen, deren Dialoge unter WSLg falsch positioniert werden;
  Xephyr wird nach der letzten Sitzung automatisch beendet
- `truecolor-test.sh` zur Prüfung der Farbtiefe des Terminals
- `install-termpp.sh` für die Einrichtung unter Windows
- Versionskennung in `VERSION`, vom vhstack-Installer per curl gelesen —
  termpp wird nicht geklont, sondern dateiweise verteilt

### Hinweis

Vor diesem Tag wurde nicht versioniert. Die Startnummer spiegelt den Reifegrad
des Projekts, nicht eine Folge früherer Releases — v1.0.0 bis v1.1.x haben nie
existiert.

[1.3.0]: https://github.com/vhstack/termpp/releases/tag/v1.3.0
[1.2.0]: https://github.com/vhstack/termpp/releases/tag/v1.2.0
