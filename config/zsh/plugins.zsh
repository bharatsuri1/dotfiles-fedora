AUTOSUGGESTIONS_PLUGIN="$ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
SYNTAX_HIGHLIGHTING_PLUGIN="$ZDOTDIR/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
FZF_TAB_PLUGIN="$ZDOTDIR/plugins/fzf-tab/fzf-tab.plugin.zsh"

# fzf-tab replaces zsh's completion menu with an fzf-powered picker. Source it
# after compinit (run in completion.zsh) and before the other plugins so it can
# wrap their completion behavior. The `menu select` zstyle in completion.zsh is
# kept as the fallback when fzf-tab is absent.
[[ -r "$FZF_TAB_PLUGIN" ]] && source "$FZF_TAB_PLUGIN"
[[ -r "$AUTOSUGGESTIONS_PLUGIN" ]] && source "$AUTOSUGGESTIONS_PLUGIN"
[[ -r "$SYNTAX_HIGHLIGHTING_PLUGIN" ]] && source "$SYNTAX_HIGHLIGHTING_PLUGIN"

unset AUTOSUGGESTIONS_PLUGIN SYNTAX_HIGHLIGHTING_PLUGIN FZF_TAB_PLUGIN
