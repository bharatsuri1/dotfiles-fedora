bindkey -v

set_cursor_shape() {
  case "$KEYMAP" in
    vicmd) printf '\e[2 q' ;;
    *) printf '\e[6 q' ;;
  esac
}

zle-line-init() {
  set_cursor_shape
}

zle-keymap-select() {
  set_cursor_shape
}

zle -N zle-line-init
zle -N zle-keymap-select
