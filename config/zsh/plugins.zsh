AUTOSUGGESTIONS_PLUGIN="$ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
SYNTAX_HIGHLIGHTING_PLUGIN="$ZDOTDIR/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

[[ -r "$AUTOSUGGESTIONS_PLUGIN" ]] && source "$AUTOSUGGESTIONS_PLUGIN"
[[ -r "$SYNTAX_HIGHLIGHTING_PLUGIN" ]] && source "$SYNTAX_HIGHLIGHTING_PLUGIN"

unset AUTOSUGGESTIONS_PLUGIN SYNTAX_HIGHLIGHTING_PLUGIN
