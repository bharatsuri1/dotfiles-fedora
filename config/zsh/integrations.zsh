for fzf_script in \
  /usr/share/fzf/shell/key-bindings.zsh \
  /usr/share/fzf/key-bindings.zsh; do
  [[ -r "$fzf_script" ]] && source "$fzf_script" && break
done
for fzf_script in \
  /usr/share/fzf/shell/completion.zsh \
  /usr/share/fzf/completion.zsh; do
  [[ -r "$fzf_script" ]] && source "$fzf_script" && break
done
unset fzf_script

if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"
command -v atuin >/dev/null && eval "$(atuin init zsh --disable-up-arrow)"
command -v starship >/dev/null && eval "$(starship init zsh)"
