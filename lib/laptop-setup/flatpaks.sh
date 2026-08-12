install_flatpaks() {
  command -v flatpak >/dev/null 2>&1 || die 'Flatpak is missing; run the packages phase first'

  if ! flatpak remotes --columns=name 2>/dev/null | grep -Fxq flathub; then
    run flatpak remote-add --if-not-exists flathub \
      https://flathub.org/repo/flathub.flatpakrepo
  fi

  local app
  for app in "${FLATPAK_APPS[@]}"; do
    if flatpak info "$app" >/dev/null 2>&1; then
      log "$app already installed"
    else
      local -a command=(flatpak install flathub)
      $ASSUME_YES && command+=(--assumeyes)
      run "${command[@]}" "$app"
    fi
  done

  run mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"
  
  if command -v chromium-browser >/dev/null 2>&1 || $DRY_RUN; then
    run xdg-settings set default-web-browser chromium-browser.desktop
  fi
}
