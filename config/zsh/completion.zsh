autoload -Uz compinit
if [[ ! -s "$XDG_CACHE_HOME/zsh/zcompdump" ]] ||
  [[ -n "$(find "$XDG_CACHE_HOME/zsh/zcompdump" -mtime +1 -print -quit 2>/dev/null)" ]]; then
  compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
else
  compinit -C -d "$XDG_CACHE_HOME/zsh/zcompdump"
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
