# 🖥️ OModerne Terminal-Arbeitsumgebung unter Windows

Diese Anleitung beschreibt, wie du dir eine moderne, performante und 
optisch ansprechende Terminal-Umgebung unter Windows aufbaust. Sie 
besteht aus:

- **Windows Terminal** (Preview-Version empfohlen)
- einer **Nerd Font** (z. B. Cascadia Code NF)
- einem modernen **Bash Prompt via Oh My Posh**

---

## 📦 Terminalwahl: Windows Terminal

Es gibt viele Terminal-Optionen unter Windows. Nach zahlreichen Tests 
habe ich mich für [**Windows Terminal**](https://aka.ms/terminal-preview) 
entschieden – es ist:

- schnell
- modern
- flexibel konfigurierbar
- schlank

Ich verwende die **Preview-Version**, um frühzeitig neue Features nutzen 
zu können.

### 🔧 Installation

Windows Terminal ist kostenlos über den Microsoft Store verfügbar:

- ▶️ [Windows Terminal Preview](https://apps.microsoft.com/detail/9n8g5rfz9xk3)

---

## 🔤 Schriftart: Nerd Font mit Symbolunterstützung

Damit Icons, Git-Symbole und hübsche Prompt-Elemente korrekt angezeigt 
werden, brauchst du eine **Nerd Font**. Ich empfehle:

### 💎 Cascadia Code Nerd Font

➡️ [Download auf nerdfonts.com](https://www.nerdfonts.com/font-downloads)

Vorteile:

- Klare Lesbarkeit
- Schönes Design
- Unterstützt **Ligaturen**
- Perfekt für Entwicklerterminals

> Nach der Installation kann die Schriftart in Windows Terminal 
(z. B. via `settings.json`) als Standard gesetzt werden. 

#### ✨ Ligaturen-Beispiele

| Eingabe  | Darstellung (Ligatur) |
|----------|------------------------|
| `->`     | →                      |
| `=>`     | ⇒                      |
| `!=`     | ≠                      |
| `==`     | ═                      |
| `===`    | ≡                      |
| `<=`     | ≤                      |

---

## ⚙️ Konfiguration von Windows Terminal

Die Anpassung erfolgt über die Datei `settings.json`.

### 📝 Vorgehensweise

1. Öffne den Terminal
2. Drücke `Ctrl + ,` (oder über Menü)
3. Klicke auf „Einstellungen (JSON-Datei öffnen)“
4. Ersetze oder ergänze den Inhalt mit deiner Konfiguration

### ⌨️ Tastenkürzel

| Tastenkombination     | Funktion                               |
|-----------------------|----------------------------------------|
| `Shift + ← / →`       | Wechsel zwischen Windows Terminal Tabs |
| `Alt + ← / →`         | Wechsel zwischen Tmux-Fenstern         |
| `Ctrl + ← / →`        | Wechsel zwischen NVim-Buffern          |

Diese Einstellungen und das Farbschema sind auf meine Konfigurationen 
von Neovim und TMux abgestimmt.

- [`vhstack/tmuxpp`](https://github.com/vhstack/tmuxpp)
- [`vhstack/nvimpp`](https://github.com/vhstack/nvimpp)

---

## 🎨 Bash Prompt mit Oh My Posh auf dem Remote-Server

Ein informatives, modernes Bash Prompt ist Gold wert. 
Mit **Oh My Posh** erhältst du:

- Git-Branch-Anzeige
- Exit-Code-Darstellung
- visuelle Trennung durch Icons und Farben

> Wichtig: Die Einrichtung erfolgt **nur auf dem Remote-Server unter Bash**, **nicht lokal**.

### 🛠️ Installation auf dem Remote-Server (Linux)

```bash
curl -s https://ohmyposh.dev/install.sh | bash -s
```

Oder nachlesen:  
👉 [Oh My Posh – Linux Installationsanleitung](https://ohmyposh.dev/docs/installation/linux)

---

## 🎨 Theme-Konfiguration für Oh My Posh

Verwende das Theme `vhstack-omp.json` oder ein beliebiges anderes 
nach deinem Geschmack.

### ✅ Schritte:

1. Kopiere `vhstack-omp.json` auf den Server, z. B.:

```bash
mkdir -p ~/.config/ohmyposh
scp vhstack-omp.json user@server:~/.config/ohmyposh/
```

2. Ergänze in `.bashrc` oder `.bash_profile`:

```bash
eval "$(oh-my-posh init bash --config ~/.config/ohmyposh/vhstack-omp.json)"
```

3. Lade die Bash neu:

```bash
. ~/.bashrc
```

Dein Shell-Prompt wird nun automatisch bei jeder Anmeldung (login) geladen.

---

## 📎 Nützliche Links

- 💻 [Windows Terminal GitHub](https://github.com/microsoft/terminal)
- 🔤 [Nerd Fonts Übersicht](https://www.nerdfonts.com/font-downloads)
- 🖌️ [Oh My Posh Dokumentation](https://ohmyposh.dev/)

---

## 🧠 Schlusswort

Mit dieser Umgebung hast du ein schlankes, schnelles und optisch 
ansprechendes Setup für deine tägliche Arbeit.

Alle Teile sind modular anpassbar – Themes, Schriftarten, Tastenkürzel, Farben.  
👉 **Dein Terminal. Dein Workflow. Dein Stil.**

Viel Spaß beim Einrichten – und happy hacking! 🚀
