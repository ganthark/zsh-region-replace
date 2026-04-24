# =============================================================================
# ZLE Selection Keybinds
# =============================================================================
# Platform-specific bindings (Ctrl+Shift on Linux/WSL, Option/Alt+Shift on macOS)
# are applied automatically based on `uname -s`.
#
# Escape codes may vary by terminal. To find yours:
#   1. Type `cat` and press Enter
#   2. Press Ctrl+V then your key combo
#   3. Override the binding in ~/.zshrc after sourcing the plugin:
#        bindkey 'YOUR_SEQUENCE' select-forward-char   # example
# =============================================================================

# --- Select by visual line (Shift+Up / Shift+Down) --------------------------
# These are the same on all platforms.
bindkey '^[[1;2A' select-up-line
bindkey '^[[1;2B' select-down-line

# --- Platform-specific bindings (macOS vs everything else) -------------------
# On macOS (tested on iTerm2), Option/Alt+Shift sends modifier code 4 (^[[1;4x).
# On Windows Terminal and most Linux terminals, Ctrl+Shift sends code 6 (^[[1;6x)
# and Ctrl alone sends code 5 (^[[1;5x).
#
# NOTE: On macOS, Cmd is intercepted by the OS/terminal before reaching ZLE
# and cannot be bound here. Cmd+X/C/V are therefore not available to the plugin.
if [[ "$(uname -s)" == Darwin ]]; then

  # Option+Shift+Up / Option+Shift+Down — select to buffer boundaries
  bindkey '^[[1;4A' select-to-buffer-start
  bindkey '^[[1;4B' select-to-buffer-end

  # Option+Up / Option+Down — jump to buffer boundaries without selection
  bindkey '^[[1;5A' jump-to-buffer-start
  bindkey '^[[1;5B' jump-to-buffer-end

  # Option+Shift+Left / Option+Shift+Right — select by word
  bindkey '^[[1;4D' select-backward-word
  bindkey '^[[1;4C' select-forward-word

  # Ctrl+V — paste from clipboard
  # On macOS, Ctrl+V has no default ZLE binding (unlike Linux/WSL where it
  # triggers quoted-insert). Without a binding it falls into literal-insert mode,
  # causing the next keypress's raw escape sequence to be written into the buffer.
  # _zsel-macos-paste-from-clipboard reads from pbpaste directly, making Ctrl+V
  # behave consistently with Cmd+V.
  bindkey '^V' _zsel-macos-paste-from-clipboard

else

  # Ctrl+Up / Ctrl+Down — jump to buffer boundaries without selection
  bindkey '^[[1;5A' jump-to-buffer-start
  bindkey '^[[1;5B' jump-to-buffer-end

  # Ctrl+Shift+Up / Ctrl+Shift+Down — select to buffer boundaries
  bindkey '^[[1;6A' select-to-buffer-start
  bindkey '^[[1;6B' select-to-buffer-end

  # Ctrl+Shift+Left / Ctrl+Shift+Right — select by word
  bindkey '^[[1;6C' select-forward-word
  bindkey '^[[1;6D' select-backward-word

  # NOTE: On Linux/WSL, Ctrl+V triggers quoted-insert by default, which is
  # already wrapped in the functions file. No explicit binding is needed here.

fi

# --- Select by character (Shift+Left / Shift+Right) -------------------------
bindkey '^[[1;2C' select-forward-char
bindkey '^[[1;2D' select-backward-char

# --- Deselect only (Escape) --------------------------------------------------
bindkey '^[' deselect-only

# --- Delete/Backspace with selection support (Delete / Backspace) -------------
bindkey '^[[3~'  delete-or-delete-selection      # Delete key
bindkey '^?'     backward-delete-or-selection    # Backspace

# =============================================================================
# NOTE: Plain arrows (Left/Right/Up/Down) and Ctrl+Left/Right deselection
# is handled by wrapping the widgets directly in the functions file,
# so no bindkey entries are needed for those here.
# =============================================================================

# --- Clipboard (Ctrl+Y = copy, Ctrl+X = cut) --------------------------------
# These bindings work on all platforms.
# Paste is handled per-platform: on macOS Ctrl+V is bound to
# _zsel-macos-paste-from-clipboard above, and Cmd+V is handled by the terminal
# via the quoted-insert wrapper in the functions file. On Linux/WSL, Ctrl+V
# triggers quoted-insert by default, which is already wrapped in the functions file.
bindkey '^Y'     copy-selection-to-clipboard
bindkey '^X'     cut-selection-to-clipboard