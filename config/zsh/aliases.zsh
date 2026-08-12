alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias c='clear'
alias l='eza -lah --group-directories-first --icons=auto'
alias ll='eza -lah --group-directories-first --icons=auto'
alias la='eza -a --group-directories-first --icons=auto'
alias tree='eza --tree --group-directories-first --icons=auto'
alias cat='bat'
alias catp='bat --plain --paging=never'
alias grep='rg --color=auto'
alias mkdir='mkdir -p'
alias vim='nvim'
alias which='type -a'
alias path='print -l $path'
alias reload='exec zsh'

alias g='git'
alias gd='git diff'
alias gds='git diff --staged'
alias glog='git log --oneline --graph --decorate'
alias gs='git status --short --branch'
alias lg='lazygit'

mkcd() {
  mkdir -p -- "$1" && cd -- "$1"
}
