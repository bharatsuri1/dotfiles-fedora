AUTOSUGGESTIONS_PLUGIN="$ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
SYNTAX_HIGHLIGHTING_PLUGIN="$ZDOTDIR/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
FZF_TAB_PLUGIN="$ZDOTDIR/plugins/fzf-tab/fzf-tab.plugin.zsh"
HISTORY_SUBSTRING_SEARCH_PLUGIN="$ZDOTDIR/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"

# fzf-tab replaces zsh's completion menu with an fzf-powered picker. Source it
# after compinit (run in completion.zsh) and before the other plugins so it can
# wrap their completion behavior. The `menu select` zstyle in completion.zsh is
# kept as the fallback when fzf-tab is absent.
[[ -r "$FZF_TAB_PLUGIN" ]] && source "$FZF_TAB_PLUGIN"
[[ -r "$AUTOSUGGESTIONS_PLUGIN" ]] && source "$AUTOSUGGESTIONS_PLUGIN"
[[ -r "$SYNTAX_HIGHLIGHTING_PLUGIN" ]] && source "$SYNTAX_HIGHLIGHTING_PLUGIN"

# Keep cycling clean when the same command appears repeatedly in history.
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
[[ -r "$HISTORY_SUBSTRING_SEARCH_PLUGIN" ]] && source "$HISTORY_SUBSTRING_SEARCH_PLUGIN"

# Type any text from a prior command, then use Up/Down to cycle only matching
# history entries. Bind both normal and application cursor-key escape codes.
if (( $+widgets[history-substring-search-up] )); then
  local keymap
  for keymap in viins emacs; do
    bindkey -M "$keymap" '^[[A' history-substring-search-up
    bindkey -M "$keymap" '^[OA' history-substring-search-up
    bindkey -M "$keymap" '^[[B' history-substring-search-down
    bindkey -M "$keymap" '^[OB' history-substring-search-down
  done
  unset keymap
fi

unset AUTOSUGGESTIONS_PLUGIN SYNTAX_HIGHLIGHTING_PLUGIN FZF_TAB_PLUGIN \
  HISTORY_SUBSTRING_SEARCH_PLUGIN
