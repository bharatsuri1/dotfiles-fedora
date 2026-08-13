for font_module in \
  jetbrains-mono-nerd \
  noto; do
  # shellcheck source=/dev/null
  source "$LIB_DIR/fonts/$font_module.sh"
done
unset font_module

font_family_installed() {
  fc-list : family 2>/dev/null | grep -Fi -- "$1" >/dev/null
}

install_fonts() {
  install_jetbrains_mono_nerd_font
  install_noto_fonts
}

show_font_status() {
  printf 'Fonts:\n'
  local family
  for family in \
    'JetBrainsMono Nerd Font' \
    'Noto Sans' \
    'Noto Serif' \
    'Noto Color Emoji' \
    'Noto Sans CJK'; do
    if font_family_installed "$family"; then
      printf '  [available] %s\n' "$family"
    else
      printf '  [missing]   %s\n' "$family"
    fi
  done
}
