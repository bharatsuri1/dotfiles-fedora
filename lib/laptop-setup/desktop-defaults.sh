readonly CHROMIUM_POLICY_SOURCE="$REPO_ROOT/config/chromium/policies.json"
readonly CHROMIUM_POLICY_TARGET="/etc/chromium/policies/managed/dotfiles-fedora.json"

set_mime_default() {
  local desktop_file="$1"
  shift

  local mime_type
  for mime_type in "$@"; do
    run xdg-mime default "$desktop_file" "$mime_type"
  done
}

install_chromium_policy() {
  log 'installing managed Chromium defaults'
  run sudo install -d -m 0755 "$(dirname -- "$CHROMIUM_POLICY_TARGET")"
  run sudo install -m 0644 "$CHROMIUM_POLICY_SOURCE" "$CHROMIUM_POLICY_TARGET"
}

install_desktop_defaults() {
  command -v xdg-mime >/dev/null 2>&1 || die 'xdg-mime is missing; run the packages phase first'

  log 'configuring desktop application defaults'
  set_mime_default chromium-browser.desktop \
    text/html \
    x-scheme-handler/http \
    x-scheme-handler/https

  set_mime_default org.gnome.Nautilus.desktop inode/directory

  set_mime_default mpv.desktop \
    audio/mpeg \
    audio/ogg \
    audio/x-flac \
    video/mp4 \
    video/webm \
    video/x-matroska

  set_mime_default imv.desktop \
    image/gif \
    image/jpeg \
    image/png \
    image/webp

  set_mime_default org.gnome.Evince.desktop application/pdf

  if command -v xdg-settings >/dev/null 2>&1; then
    run xdg-settings set default-web-browser chromium-browser.desktop
  fi

  install_chromium_policy
}
