# =============================================================================
# ZLE Selection Functions
# =============================================================================

# --- Region highlight --------------------------------------------------------
zle_highlight=(region:bg=blue,fg=white)

# --- Save original widgets with unique prefix --------------------------------
zle -A forward-char         _zsel-orig-forward-char
zle -A backward-char        _zsel-orig-backward-char
zle -A forward-word         _zsel-orig-forward-word
zle -A backward-word        _zsel-orig-backward-word
zle -A up-line-or-history   _zsel-orig-up-line-or-history
zle -A down-line-or-history _zsel-orig-down-line-or-history
zle -A quoted-insert        _zsel-orig-quoted-insert
zle -A bracketed-paste      _zsel-orig-bracketed-paste
zle -A self-insert          _zsel-orig-self-insert
zle -A self-insert-unmeta   _zsel-orig-self-insert-unmeta

# --- Shared deactivate helper ------------------------------------------------
_zsel-deactivate() {
  REGION_ACTIVE=0
  MARK=$CURSOR
  zle deactivate-region
}

# --- Selection widgets -------------------------------------------------------
# Call _zsel-orig-* directly to bypass our own deselect wrappers

select-forward-char() {
  (( !REGION_ACTIVE )) && zle set-mark-command
  zle _zsel-orig-forward-char
}
zle -N select-forward-char

select-backward-char() {
  (( !REGION_ACTIVE )) && zle set-mark-command
  zle _zsel-orig-backward-char
}
zle -N select-backward-char

select-forward-word() {
  (( !REGION_ACTIVE )) && zle set-mark-command
  zle _zsel-orig-forward-word
}
zle -N select-forward-word

select-backward-word() {
  (( !REGION_ACTIVE )) && zle set-mark-command
  zle _zsel-orig-backward-word
}
zle -N select-backward-word

# --- Deselect wrappers -------------------------------------------------------
# Replace original widgets so deselection works regardless of how they are triggered

forward-char() {
  (( REGION_ACTIVE )) && _zsel-deactivate
  zle _zsel-orig-forward-char
}
zle -N forward-char

backward-char() {
  (( REGION_ACTIVE )) && _zsel-deactivate
  zle _zsel-orig-backward-char
}
zle -N backward-char

forward-word() {
  (( REGION_ACTIVE )) && _zsel-deactivate
  zle _zsel-orig-forward-word
}
zle -N forward-word

backward-word() {
  (( REGION_ACTIVE )) && _zsel-deactivate
  zle _zsel-orig-backward-word
}
zle -N backward-word

up-line-or-history() {
  (( REGION_ACTIVE )) && _zsel-deactivate
  zle _zsel-orig-up-line-or-history
}
zle -N up-line-or-history

down-line-or-history() {
  (( REGION_ACTIVE )) && _zsel-deactivate
  zle _zsel-orig-down-line-or-history
}
zle -N down-line-or-history

deselect-only() {
  _zsel-deactivate
}
zle -N deselect-only

# --- WSL clipboard helper ---------------------------------------------------
# clip.exe may not be on PATH in VSCode-launched terminals.
# Fall back to the known Windows system path.

_zsel-clip-exe() {
  if command -v clip.exe &>/dev/null; then
    clip.exe
  elif [[ -x /mnt/c/Windows/System32/clip.exe ]]; then
    /mnt/c/Windows/System32/clip.exe
  fi
}

# --- Select by visual line (Shift+Up / Shift+Down) --------------------------
# Builds a table of every visual row's start offset, accounting for both
# \n-terminated logical lines and long lines that wrap at $COLUMNS.
# The prompt width is subtracted from the first row's available width since
# it occupies columns before the buffer starts.
#
# KNOWN BUG: ZLE's region highlight rendering does not correctly colour across
# visual line-wrap boundaries. The selection is functionally correct (deleting
# it removes the right characters) but the highlight may appear incomplete when
# the selection spans a wrapped line. The `zle -R` call forces an immediate
# redraw but does not resolve the underlying rendering problems.

_zsel-visual-rows() {
  _zsel_rows=()
  _zsel_row_widths=()

  local row_start=0
  local first=1
  local -a lines
  lines=("${(@f)BUFFER}")

  local l
  for l in $lines; do
    local llen=$#l
    local avail=$(( first ? COLUMNS - ${#${(%)PROMPT}} : COLUMNS ))
    first=0
    local vstart=$row_start

    # Consume full wrap-width chunks first
    while (( llen > avail )); do
      _zsel_rows+=($vstart)
      _zsel_row_widths+=($avail)
      vstart=$(( vstart + avail ))
      llen=$(( llen - avail ))
      avail=$COLUMNS
    done

    # Remaining (or entire) logical line fits in one visual row
    _zsel_rows+=($vstart)
    _zsel_row_widths+=($llen)
    row_start=$(( vstart + llen + 1 ))  # +1 for the \n
  done

  # Find which visual row the cursor is currently on
  _zsel_cur_row=1
  local i
  for (( i = $#_zsel_rows; i >= 1; i-- )); do
    if (( CURSOR >= _zsel_rows[i] )); then
      _zsel_cur_row=$i
      break
    fi
  done
}

select-up-line() {
  (( !REGION_ACTIVE )) && zle set-mark-command
  _zsel-visual-rows
  if (( _zsel_cur_row == 1 )); then
    CURSOR=0
  else
    local col=$(( CURSOR - _zsel_rows[_zsel_cur_row] ))
    local p=$(( _zsel_cur_row - 1 ))
    local target=$(( _zsel_rows[p] + col ))
    local max=$(( _zsel_rows[p] + _zsel_row_widths[p] ))
    CURSOR=$(( target > max ? max : target ))
  fi
  zle -R
}
zle -N select-up-line

select-down-line() {
  (( !REGION_ACTIVE )) && zle set-mark-command
  _zsel-visual-rows
  if (( _zsel_cur_row == $#_zsel_rows )); then
    CURSOR=$#BUFFER
  else
    local col=$(( CURSOR - _zsel_rows[_zsel_cur_row] ))
    local n=$(( _zsel_cur_row + 1 ))
    local target=$(( _zsel_rows[n] + col ))
    local max=$(( _zsel_rows[n] + _zsel_row_widths[n] ))
    CURSOR=$(( target > max ? max : target ))
  fi
  zle -R
}
zle -N select-down-line

# --- Select to buffer boundaries (Ctrl+Shift+Up / Ctrl+Shift+Down) ----------

select-to-buffer-start() {
  (( !REGION_ACTIVE )) && zle set-mark-command
  CURSOR=0
  zle -R
}
zle -N select-to-buffer-start

select-to-buffer-end() {
  (( !REGION_ACTIVE )) && zle set-mark-command
  CURSOR=$#BUFFER
  zle -R
}
zle -N select-to-buffer-end

# --- Jump to buffer boundaries without selection (Ctrl+Up / Ctrl+Down) ------

jump-to-buffer-start() {
  (( REGION_ACTIVE )) && _zsel-deactivate
  CURSOR=0
}
zle -N jump-to-buffer-start

jump-to-buffer-end() {
  (( REGION_ACTIVE )) && _zsel-deactivate
  CURSOR=$#BUFFER
}
zle -N jump-to-buffer-end

# --- Delete selection helper -------------------------------------------------
# Removes the selected region without touching the kill ring.
# Rebuilds BUFFER from the parts outside [start, end].

_zsel-delete-selection() {
  local start=$(( MARK < CURSOR ? MARK : CURSOR ))
  local end=$(( MARK < CURSOR ? CURSOR : MARK ))
  BUFFER="${BUFFER[1,start]}${BUFFER[end+1,-1]}"
  CURSOR=$start
  _zsel-deactivate
}
zle -N _zsel-delete-selection

# --- Backspace / Delete with selection awareness ----------------------------

delete-or-delete-selection() {
  if (( REGION_ACTIVE )); then
    _zsel-delete-selection
  else
    zle delete-char
  fi
}
zle -N delete-or-delete-selection

backward-delete-or-selection() {
  if (( REGION_ACTIVE )); then
    _zsel-delete-selection
  else
    zle backward-delete-char
  fi
}
zle -N backward-delete-or-selection

# --- Character insert with selection awareness ------------------------------
# Registered via a one-shot precmd hook so that it runs after all other plugins
# have loaded

self-insert() {
  (( REGION_ACTIVE )) && _zsel-delete-selection
  zle _zsel-orig-self-insert
}

self-insert-unmeta() {
  (( REGION_ACTIVE )) && _zsel-delete-selection
  zle _zsel-orig-self-insert-unmeta
}

_zsel-bind-self-insert() {
  zle -N self-insert
  zle -N self-insert-unmeta
  add-zsh-hook -d precmd _zsel-bind-self-insert
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _zsel-bind-self-insert

# --- Clipboard provider detection --------------------------------------------
# Returns one of: wsl | macos | xclip | none
# WSL   : detected via $WSL_DISTRO_NAME (set automatically by the WSL kernel)
# macOS : detected via `uname -s` returning Darwin
# xclip : fallback for native Linux with X11; requires xclip to be installed

_zsel-clipboard-provider() {
  if [[ -n "${WSL_DISTRO_NAME}" ]]; then
    echo wsl
  elif [[ "$(uname -s)" == Darwin ]]; then
    echo macos
  elif command -v xclip &>/dev/null; then
    echo xclip
  else
    echo none
  fi
}

# --- Copy selection to clipboard (Ctrl+Y) ------------------------------------
# Silently does nothing if there is no active selection.

copy-selection-to-clipboard() {
  (( !REGION_ACTIVE )) && return
  local start=$(( MARK < CURSOR ? MARK : CURSOR ))
  local end=$(( MARK < CURSOR ? CURSOR : MARK ))
  local text="${BUFFER[start+1,end]}"
  case "$(_zsel-clipboard-provider)" in
    wsl)   printf '%s' "$text" | _zsel-clip-exe ;;
    macos) printf '%s' "$text" | pbcopy ;;
    xclip) printf '%s' "$text" | xclip -selection clipboard ;;
  esac
  _zsel-deactivate
}
zle -N copy-selection-to-clipboard

# --- Cut selection to clipboard (Ctrl+X) -------------------------------------
# Copies selection then deletes it. Silently does nothing if no selection.

cut-selection-to-clipboard() {
  (( !REGION_ACTIVE )) && return
  local start=$(( MARK < CURSOR ? MARK : CURSOR ))
  local end=$(( MARK < CURSOR ? CURSOR : MARK ))
  local text="${BUFFER[start+1,end]}"
  case "$(_zsel-clipboard-provider)" in
    wsl)   printf '%s' "$text" | clip.exe ;;
    macos) printf '%s' "$text" | pbcopy ;;
    xclip) printf '%s' "$text" | xclip -selection clipboard ;;
  esac
  _zsel-delete-selection
}
zle -N cut-selection-to-clipboard

# --- macOS: Paste from clipboard (Ctrl+V) ------------------------------------
# On macOS, Ctrl+V has no default ZLE binding. Unlike Cmd+V (which is handled
# by the terminal and injects clipboard content as bracketed paste), Ctrl+V
# reaches ZLE directly but carries no clipboard data. This widget reads from
# pbpaste explicitly so that Ctrl+V can paste like Cmd+V does.
# This widget is defined on all platforms but only bound on macOS (see keybindings).

_zsel-macos-paste-from-clipboard() {
  (( REGION_ACTIVE )) && _zsel-delete-selection
  local text
  text=$(pbpaste)
  LBUFFER+="$text"
}
zle -N _zsel-macos-paste-from-clipboard

# --- Paste wrappers (Cmd+V on macOS, Ctrl+V on Linux/WSL) -------------------
# Paste reaches ZLE via two different widgets depending on the platform:
#   - bracketed-paste : The terminal intercepts the paste keystroke and injects
#                       clipboard content wrapped in ESC[200~...ESC[201~ before
#                       ZLE sees it. Used by Windows Terminal and most modern
#                       terminals on Linux/WSL.
#   - quoted-insert   : On macOS, Cmd+V is intercepted by the terminal and mapped
#                       to quoted-insert, which ZLE then handles directly.
# Both are wrapped identically here so selection replacement works regardless of
# which path the platform takes.
# NOTE: On macOS, Ctrl+V is handled separately via _zsel-macos-paste-from-clipboard
# (see above) and does not go through either of these widgets.

bracketed-paste() {
  (( REGION_ACTIVE )) && _zsel-delete-selection
  zle _zsel-orig-bracketed-paste
}
zle -N bracketed-paste

quoted-insert() {
  (( REGION_ACTIVE )) && _zsel-delete-selection
  zle _zsel-orig-quoted-insert
}
zle -N quoted-insert