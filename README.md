# zsh-editor-selection

> [!IMPORTANT]
> Please take a look at [zsh-edit-select](https://github.com/Michael-Matta1/zsh-edit-select)!  
> It is a more fully-featured alternative with undo/redo, mouse integration, advanced clipboard
> agents, and an interactive config wizard.
> Check it out first if you need a complete text-editor experience in your shell!

> Repository name changed from **zsh-editor-selection** to **zsh-region-replace** to avoid confusion with [zsh-edit-select](https://github.com/Michael-Matta1/zsh-edit-select).  

**A Zsh plugin that brings familiar text-editor selection behaviour to the Zsh Line Editor.**

- 🔡 **Select** by character, word, or visual line using Shift-modified keys
- 📋 **Copy, cut, and paste** via the system clipboard
- ✏️ **Type to replace** an active selection
- ➡️ **Plain cursor movement** deselects automatically
- 🖥️ Supports **WSL, macOS, and native Linux**

![demo](https://github.com/user-attachments/assets/d97bfd76-9abb-4172-b6d2-f681ea82f052)

## Key Bindings

### All platforms

| Key           | Action                                 |
|---------------|----------------------------------------|
| `Shift+Right` | Select character forward               |
| `Shift+Left`  | Select character backward              |
| `Shift+Down`  | Select visual line down                |
| `Shift+Up`    | Select visual line up                  |
| `Ctrl+Y`      | Copy selection to clipboard            |
| `Ctrl+X`      | Cut selection to clipboard             |
| `Delete`      | Delete selection or next character     |
| `Backspace`   | Delete selection or previous character |
| `Escape`      | Deselect                               |

### Linux / WSL

| Key                | Action                               |
|--------------------|--------------------------------------|
| `Ctrl+Shift+Right` | Select word forward                  |
| `Ctrl+Shift+Left`  | Select word backward                 |
| `Ctrl+Shift+Down`  | Select to buffer end                 |
| `Ctrl+Shift+Up`    | Select to buffer start               |
| `Ctrl+Down`        | Jump to buffer end                   |
| `Ctrl+Up`          | Jump to buffer start                 |
| `Ctrl+V`           | Paste (replaces selection if active) |

### macOS

| Key                  | Action                               |
|----------------------|--------------------------------------|
| `Option+Shift+Right` | Select word forward                  |
| `Option+Shift+Left`  | Select word backward                 |
| `Option+Shift+Down`  | Select to buffer end                 |
| `Option+Shift+Up`    | Select to buffer start               |
| `Option+Down`        | Jump to buffer end                   |
| `Option+Up`          | Jump to buffer start                 |
| `Cmd+V`              | Paste (replaces selection if active) |
| `Ctrl+V`             | Paste (replaces selection if active) |

## Requirements

| Platform  | Clipboard tool        | Status      |
|-----------|-----------------------|-------------|
| WSL       | `clip.exe` (built-in) | ✅ Tested   |
| macOS     | `pbcopy` (built-in)   | ✅ Tested   |
| Linux/X11 | `xclip`               | ⚠️ Untested |

*Please feel free to test on Linux/X11 and report your findings!*

## Installation

### Oh My Zsh

```zsh
git clone https://github.com/Ganthark/zsh-editor-selection \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-editor-selection
```

Then add the plugin to your `~/.zshrc`:

```zsh
plugins=(... zsh-editor-selection)
```

### Sheldon

```toml
[plugins.zsh-editor-selection]
github = "Ganthark/zsh-editor-selection"
```

### Manual

```zsh
git clone https://github.com/Ganthark/zsh-editor-selection
echo "source ~/path/to/zsh-editor-selection/zsh-editor-selection.plugin.zsh" >> ~/.zshrc
```

---

## Changing key bindings

Escape codes for modifier+arrow keys vary by terminal. The defaults in this plugin target **Windows Terminal**, **iTerm2**, and most modern VTE-based terminals. If a binding doesn't work, find your terminal's code like so:

1. Run `cat` and press Enter
2. Press your key combo — on Linux/WSL you can also use `Ctrl+V` before the combo to reveal the raw sequence
3. Note the printed escape sequence
4. Override the binding in your `~/.zshrc` **after** sourcing the plugin:

```zsh
bindkey 'YOUR_SEQUENCE' select-forward-char   # example
```

---

## Known Limitations

**Visual line wrap highlight rendering** — when a selection spans a line that wraps at the terminal column boundary, ZLE's region highlight may not colour the wrapped portion correctly in WSL. The selection is functionally correct (deleting it removes the right characters). I am unsure I can solve this issue so feel free to send your suggestions!

**Cmd+C / Cmd+X / Cmd+V on macOS** — the `Cmd` key is intercepted by the OS and terminal before reaching ZLE, so these keystrokes cannot be bound by the plugin. `Ctrl+Y` (copy), `Ctrl+X` (cut), and `Ctrl+V` (paste) are provided as alternatives and work on all platforms. `Cmd+V` paste still works as the terminal maps it to ZLE's `quoted-insert`.

## Closing remarks

This is my first zsh plugin and I hope I respected the usual conventions but feel free to contact me if anything is wrong or if you have any remarks/suggestions.  

## Acknowledgements  

A lot of refactor, comments and general help prototyping and debugging was done using Claude Sonnet 4.6 By Anthropic.

Demo GIF made using [asciinema](https://asciinema.org/)/[asciinema gif generator](https://github.com/asciinema/agg)
