<p align="right">
  <a href="README.md"><img src="assets/flag-de.png" width="16" height="12" alt="Deutsch" title="Zur deutschen Version wechseln" /></a>  
  <a href="README.en.md"><img src="assets/flag-gb.png" width="16" height="12" alt="English" title="Switch to English" /></a>  
  <a href="README.ru.md"><img src="assets/flag-ru.png" width="16" height="12" alt="Русский" title="Переключиться на русскую версию" /></a>
</p>

# 🖥️ Современная терминальная среда в Windows

В этом руководстве описывается, как создать современную, производительную и эстетически привлекательную терминальную среду в Windows. Она включает в себя:

- **Windows Terminal** (рекомендуется Preview-версия)
- **Nerd Font** (например, Cascadia Code NF)
- современный **Bash Prompt с Oh My Posh**

Руководство состоит из двух частей: **часть 1** — настройка терминала локально 
в Windows, **часть 2** — настройка Prompt на удалённом сервере.

![Скриншот](assets/screenshot.jpg)

---

## ⚡ Быстрый старт: полная установка vhstack на сервере

Если вы хотите настроить всю рабочую среду vhstack — **Oh My Posh Prompt**,
**Tmux** ([`vhstack/tmuxpp`](https://github.com/vhstack/tmuxpp)) и **Neovim**
([`vhstack/nvimpp`](https://github.com/vhstack/nvimpp)) — за один шаг на
сервере, используйте скрипт [`install-vhstack.sh`](./install-vhstack.sh):

```bash
curl -sL https://raw.githubusercontent.com/vhstack/termpp/main/install-vhstack.sh | bash
```

Скрипт автоматически выполняет:

- **Резервное копирование** существующих конфигураций в
  `~/.vhstack-backup-<метка времени>` (`~/.tmux*`, `~/.config/nvim`, данные
  плагинов Neovim, тема Prompt, а также копия `~/.bashrc`/`~/.zshrc`)
- Установку **Oh My Posh** с темой `vhstack.omp.json` и строкой
  инициализации в `~/.bashrc` или `~/.zshrc`
- **Конфигурацию Tmux**, включая TPM и плагины
- **Конфигурацию Neovim**, включая синхронизацию плагинов (headless)
- **Скрипт xssh** в `~/.local/bin` (X11 через Xephyr, см. ниже)
- **Команду update-vhstack** в `~/.local/bin` для последующих обновлений

**Обновление позже:** Существующую установку обновляет команда
`update-vhstack` (или [`update-vhstack.sh`](./update-vhstack.sh)) — тема,
конфигурации Tmux и Neovim вместе с плагинами, не затрагивая
`~/.bashrc`/`~/.zshrc`. Заменяемые конфигурации предварительно
сохраняются в `~/.vhstack-backup-update-<метка времени>`:

```bash
update-vhstack   # или:
curl -sL https://raw.githubusercontent.com/vhstack/termpp/main/update-vhstack.sh | bash
```

Требования: `git` и `curl`; также должны быть установлены `tmux` и `nvim`:

```bash
sudo apt install tmux neovim ripgrep clangd   # Debian/Ubuntu
brew install tmux neovim ripgrep llvm         # macOS
```

> **Совет:** После установки запустите новую оболочку (или `source ~/.bashrc`) и
> откройте `tmux` и `nvim` по одному разу. При необходимости выполните в
> Neovim `:MasonInstall clangd cmake-language-server` для C/C++ LSP.

---

## 🪟 Часть 1: Windows Terminal (локально)

### Выбор терминала

Существует множество вариантов терминалов для Windows. После многочисленных тестов я выбрал [**Windows Terminal**](https://aka.ms/terminal-preview) – он:

- быстрый  
- современный  
- гибко настраиваемый  
- легковесный  

Я использую **Preview-версию**, чтобы опробовать новые функции раньше всех. 
Windows Terminal доступен бесплатно в Microsoft Store:

- [Windows Terminal Preview](https://apps.microsoft.com/detail/9n8g5rfz9xk3)

### Шрифт: Nerd Font с поддержкой иконок

Для корректного отображения иконок, символов Git и элементов prompt необходима **Nerd Font**. 
Рекомендую [**Cascadia Code NF**](https://github.com/microsoft/cascadia-code):

- Чёткая читаемость  
- Элегантный дизайн  
- Поддержка **лигатур**  
- Идеально подходит для терминалов разработчика

> После установки шрифт можно выбрать в Windows Terminal через `settings.json` как основной.

Примеры лигатур:

| Ввод    | Отображение (лигатура) |
|---------|------------------------|
| `->`    | →                      |
| `=>`    | ⇒                      |
| `!=`    | ≠                      |
| `==`    | ═                      |
| `===`   | ≡                      |
| `<=`    | ≤                      |

Альтернативно можно установить любой другой Nerd Font по вкусу: 
[nerdfonts.com](https://www.nerdfonts.com/font-downloads)

### Настройка Windows Terminal

Конфигурация выполняется в файле `settings.json`:

1. Откройте Windows Terminal  
2. Нажмите `Ctrl + ,` (или выберите «Настройки» в меню)  
3. Откройте `settings.json`  
4. Добавьте или измените нужные параметры

Подходящий шаблон находится в этом репозитории: [`settings.json`](./settings.json)

В `profiles.list[]` можно создавать профили SSH для подключения к удалённым серверам:

```json
{
    "commandline": "ssh username@server.address",
    "hidden": false,
    "icon": "\ud83d\udda5",
    "name": "Мой SSH-сервер"
}
```

Для использования специфического SSH-ключа:

```json
"commandline": "ssh -i ~/.ssh/id_ed25519 username@server.address"
```

Создание нового SSH-ключа:

```sh
ssh-keygen -t ed25519 -C "ваш комментарий"
```

**Графические приложения с удалённого сервера (X11 через WSLg):**
WSL2 включает собственный X-сервер (WSLg) — дополнительный X-сервер под 
Windows больше не нужен. SSH-соединение устанавливается из WSL; X-программы 
сервера отображаются как обычные окна Windows:

```json
"commandline": "wsl.exe -- ssh -X -i ~/.ssh/id_ed25519 username@server.address"
```

Требования: актуальный WSL (`wsl --update`); на сервере установлен `xauth` 
и включено `X11Forwarding yes` (в Debian/Ubuntu — по умолчанию).

**Старые X-приложения** (например, старые Qt/Motif), у которых диалоги и 
всплывающие окна позиционируются неправильно под WSLg, требуют классического 
X-экрана с оконным менеджером. Это берёт на себя скрипт [`xssh`](./xssh) 
(Xephyr + openbox). Установка (однократно, в WSL):

```bash
sudo apt install xserver-xephyr openbox x11-utils
curl -sL https://raw.githubusercontent.com/vhstack/termpp/main/xssh -o ~/.local/bin/xssh && chmod +x ~/.local/bin/xssh
```

При необходимости вызывайте из оболочки WSL — параметры как у `ssh`. Окно 
Xephyr открывается при первом вызове, принимает все X-окна сессии и 
автоматически закрывается после завершения последней сессии:

```bash
xssh username@server.address
```

### Горячие клавиши

| Сочетание            | Действие                                  |
|----------------------|-------------------------------------------|
| `Shift + ← / →`      | Переключение вкладок в Windows Terminal   |
| `Alt + ← / →`        | Переключение окон Tmux                    |
| `Ctrl + ← / →`       | Переключение буферов Neovim               |

Эти настройки и цветовая схема согласованы с моими конфигурациями Neovim и Tmux:

- [`vhstack/tmuxpp`](https://github.com/vhstack/tmuxpp)
- [`vhstack/nvimpp`](https://github.com/vhstack/nvimpp)

---

## 🐧 Часть 2: Prompt на удалённом сервере

### Поддержка True Color

Убедитесь, что переменная `TERM` установлена в `xterm-256color`.  
Добавьте в `.bashrc`, `.zshrc` или `.profile`:

```bash
export TERM=xterm-256color
```

Скрипт [`truecolor-test.sh`](./truecolor-test.sh) поможет проверить поддержку 24-битного цвета. Запустите:

```bash
curl -sL https://raw.githubusercontent.com/vhstack/termpp/main/truecolor-test.sh | bash
```

Скрипт выводит плавный градиент. Если терминал поддерживает только 256 цветов, градиент будет ступенчатым; при True Color — плавным.

**256 цветов (xterm-256color с fallback 8-bit):**  
![256 цветов](assets/screenshot-256color.png)

**True Color (24-bit):**  
![True Color](assets/screenshot-truecolor.png)

### Bash Prompt с Oh My Posh

Информативный и современный Bash Prompt — бесценен. С **Oh My Posh** вы получаете:

- Отображение ветки Git  
- Код завершения последней команды  
- Визуальное разделение через иконки и цвета

> Важно: настройка производится **только** на удалённом сервере в Bash, **не локально**.

#### Быстрая установка

Тему vhstack-Prompt можно установить автоматически скриптом
[`install-termpp.sh`](./install-termpp.sh) — выполните его прямо в терминале
(Bash или Zsh):

```bash
curl -sL https://raw.githubusercontent.com/vhstack/termpp/main/install-termpp.sh | bash
```

```zsh
curl -sL https://raw.githubusercontent.com/vhstack/termpp/main/install-termpp.sh | zsh
```

Скрипт автоматически:

- Устанавливает **Oh My Posh** (если ещё не установлен)  
- Копирует тему `vhstack.omp.json` в `~/.config/ohmyposh/`  
- Добавляет в `~/.bashrc` или `~/.zshrc` строку инициализации

> **Совет:** После установки выполните `source ~/.bashrc` или `source ~/.zshrc` — или перезапустите терминал.

#### Ручная установка

Вместо скрипта шаги можно выполнить по отдельности:

1. Установите Oh My Posh (подробности в
   [руководстве по установке для Linux](https://ohmyposh.dev/docs/installation/linux)):

   ```bash
   curl -s https://ohmyposh.dev/install.sh | bash -s
   ```

2. Скопируйте тему `vhstack.omp.json` — или любую другую на ваш вкус — в
   каталог `~/.config/ohmyposh`:

   ```bash
   mkdir -p ~/.config/ohmyposh
   curl -L https://raw.githubusercontent.com/vhstack/termpp/main/vhstack.omp.json -o ~/.config/ohmyposh/vhstack.omp.json
   ```

3. Добавьте в `~/.bashrc` или `~/.zshrc`:

   ```bash
   eval "$(~/.local/bin/oh-my-posh init bash --config ~/.config/ohmyposh/vhstack.omp.json)"
   ```

4. Перезагрузите конфигурацию оболочки:

   ```bash
   . ~/.bashrc
   ```

Теперь ваш prompt будет автоматически загружаться при входе в систему.

---

## 📎 Полезные ссылки

- [Windows Terminal GitHub](https://github.com/microsoft/terminal)
- [Microsoft Cascadia Font](https://github.com/microsoft/cascadia-code)
- [Nerd Fonts Overview](https://www.nerdfonts.com/font-downloads)
- [WSLg (GUI-приложения в WSL)](https://github.com/microsoft/wslg)
- [Oh My Posh Documentation](https://ohmyposh.dev/)

---

## 🎯 Заключение

С этой средой вы получите лёгкую, быструю и эстетичную конфигурацию для ежедневной работы. Все компоненты модульны — темы, шрифты, горячие клавиши и цвета легко настраиваются под вас.  

Приятной настройки и happy hacking! 🚀
