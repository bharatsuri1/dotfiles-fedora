brew_path() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
  elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    printf '%s\n' /home/linuxbrew/.linuxbrew/bin/brew
  fi
}

install_homebrew() {
  local brew
  brew="$(brew_path || true)"

  if [[ -z "$brew" ]]; then
    if $DRY_RUN; then
      log 'would download, inspect, and run the official Homebrew installer'
      brew=/home/linuxbrew/.linuxbrew/bin/brew
    else
      local installer
      installer="$(mktemp)"
      curl -fsSLo "$installer" \
        https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
      log "Homebrew installer downloaded to $installer"
      if ! confirm 'Run the official Homebrew installer now?'; then
        die "Homebrew installation declined; inspect $installer and rerun this phase"
      fi
      if $ASSUME_YES; then
        NONINTERACTIVE=1 /bin/bash "$installer"
      else
        /bin/bash "$installer"
      fi
      brew="$(brew_path || true)"
      [[ -n "$brew" ]] || die 'Homebrew installation did not produce a brew executable'
    fi
  else
    log "Homebrew already installed at $brew"
  fi

  local extra_tap
  for extra_tap in "${BREW_TRUST_TAPS[@]}"; do
    run "$brew" trust --formula "$extra_tap"
  done

  local formula
  for formula in "${BREW_FORMULAE[@]}"; do
    if [[ -x "$brew" ]] && "$brew" list --formula "$formula" >/dev/null 2>&1; then
      log "$formula already installed"
    else
      run "$brew" install "$formula"
    fi
  done
}
