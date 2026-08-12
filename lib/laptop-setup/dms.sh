install_dms() {
  enable_copr avengemedia/dms

  if package_installed dms; then
    log 'DMS already installed'
  else
    log 'installing DMS without optional weak dependencies'
    local -a command=(sudo dnf install --setopt=install_weak_deps=False)
    $ASSUME_YES && command+=(--assumeyes)
    run "${command[@]}" dms
  fi

  if systemctl --user list-dependencies niri.service 2>/dev/null | grep -Fq dms.service; then
    log 'DMS already attached to the niri user service'
  else
    run systemctl --user add-wants niri.service dms.service
  fi
}
