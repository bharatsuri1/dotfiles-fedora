alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias c='clear'
alias mkdir='mkdir -p'
alias which='type -a'
alias path='print -l $path'
alias reload='exec zsh'
alias cx='codex --profile dotfiles --dangerously-bypass-approvals-and-sandbox --dangerously-bypass-hook-trust'
alias zed='flatpak run dev.zed.Zed'
alias tl='sesh picker'
alias tk='tmux kill-server'
alias wifi='wlctl'
alias bt='bluetui'
alias audio='wiremix'

t() {
  local session_name="${1:-home}"

  if [[ -n "$TMUX" ]]; then
    tmux has-session -t "=$session_name" 2>/dev/null ||
      tmux new-session -d -s "$session_name" -c "$HOME"
    tmux switch-client -t "=$session_name"
  else
    tmux new-session -A -s "$session_name" -c "$HOME"
  fi
}

if command -v eza >/dev/null; then
  alias l='eza -lah --group-directories-first --icons=auto'
  alias ll='eza -lah --group-directories-first --icons=auto'
  alias la='eza -a --group-directories-first --icons=auto'
  alias tree='eza --tree --group-directories-first --icons=auto'
fi

if command -v bat >/dev/null; then
  alias cat='bat'
  alias catp='bat --plain --paging=never'
fi

command -v df >/dev/null && alias df='df -h'
command -v du >/dev/null && alias du='du -h'
command -v free >/dev/null && alias free='free -h'
command -v ss >/dev/null && alias ports='ss -tulpn'
command -v ip >/dev/null && alias ip='ip --color=auto'
command -v diff >/dev/null && alias diff='diff --color=auto'
command -v rg >/dev/null && alias grep='rg --color=auto'
command -v nvim >/dev/null && alias vim='nvim'
command -v lazygit >/dev/null && alias lg='lazygit'
command -v lazydocker >/dev/null && alias ld='lazydocker'

if command -v git >/dev/null; then
  alias g='git'
  alias gd='git diff'
  alias gds='git diff --staged'
  alias glog='git log --oneline --graph --decorate'
  alias gs='git status --short --branch'
fi

mkcd() {
  mkdir -p -- "$1" && cd -- "$1"
}

# Prevent sleep/idle until Ctrl-C, or wrap a command (macOS caffeinate-style).
# Does not pause Swayidle lock/DPMS — only blocks suspend via logind.
caffeinate() {
  if (( $# )); then
    systemd-inhibit --what=sleep:idle --who=caffeinate --why="$*" -- "$@"
  else
    systemd-inhibit --what=sleep:idle --who=caffeinate --why="Keep awake" -- sleep infinity
  fi
}
