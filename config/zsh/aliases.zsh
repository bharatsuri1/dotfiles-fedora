alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias c='clear'
alias mkdir='mkdir -p'
alias which='type -a'
alias path='print -l $path'
alias reload='exec zsh'
alias cx='codex --profile dotfiles --dangerously-bypass-approvals-and-sandbox --dangerously-bypass-hook-trust'
alias sol='codex --profile dotfiles --dangerously-bypass-approvals-and-sandbox --dangerously-bypass-hook-trust -c model="gpt-5.6-sol"'
alias terra='codex --profile dotfiles --dangerously-bypass-approvals-and-sandbox --dangerously-bypass-hook-trust -c model="gpt-5.6-terra"'
alias luna='codex --profile dotfiles --dangerously-bypass-approvals-and-sandbox --dangerously-bypass-hook-trust -c model="gpt-5.6-luna"'
alias zed='flatpak run dev.zed.Zed'
alias code='flatpak run com.visualstudio.code'
alias tl='sesh picker'
alias tk='tmux kill-server'
alias wifi='wlctl'
alias bt='bluetui'
alias audio='wiremix'

t() {
  local session_name="${1:-home}"

  if [[ "$session_name" == "home" ]]; then
    sesh connect home
    return
  fi

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
if command -v nvim >/dev/null; then
  alias v='nvim'
  alias vi='nvim'
  alias vim='nvim'
fi
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

# Pick a pi model from `pi --list-models` via a fuzzy gum chooser, then launch it.
# Falls back to passing args straight through to `pi` when gum isn't installed.
pim() {
  if ! command -v gum >/dev/null 2>&1; then
    pi "$@"
    return $?
  fi
  local line provider model
  line=$(pi --list-models 2>/dev/null | tail -n +2 |
    gum filter --height=35 --fuzzy \
      --header='  Select a model' --header.foreground=99 \
      --prompt='› ' --prompt.foreground=240 \
      --placeholder='type to fuzzy-match model or provider...' \
      --indicator='▶' --indicator.foreground=212 \
      --match.foreground=212) || return
  [[ -z "$line" ]] && return
  read -r provider model _ <<< "$line"
  pi --model "${provider}/${model}"
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
