for font_module in \
  jetbrains-mono-nerd \
  ui \
  noto; do
  # shellcheck source=/dev/null
  source "$LIB_DIR/fonts/$font_module.sh"
done
unset font_module

font_family_installed() {
  fc-list : family 2>/dev/null | grep -Fi -- "$1" >/dev/null
}

install_fonts() {
  section Fonts
  install_jetbrains_mono_nerd_font
  install_ui_fonts
  install_noto_fonts
}

show_font_status() {
  section Fonts
  local family
  for family in \
    'JetBrainsMono Nerd Font' \
    "$UI_FONT_FAMILY" \
    'Noto Sans' \
    'Noto Serif' \
    'Noto Color Emoji' \
    'Noto Sans CJK'; do
    if font_family_installed "$family"; then
      report ok "$family"
    else
      report missing "$family"
    fi
  done
}
