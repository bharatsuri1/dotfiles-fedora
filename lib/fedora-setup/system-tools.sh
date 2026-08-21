# ── System tools phase ───────────────────────────────────────────────
# Installs terminal-based system management TUIs:
#   • diskonaut   — visual treemap disk usage analyzer      (Fedora DNF)
#   • powertop    — power consumption monitor and tuner     (Fedora DNF)
#   • systemctl-tui — systemd service and log browser        (GitHub binary)
#   • bandwhich   — per-process bandwidth monitor           (GitHub binary)
#   • batctl      — battery charge threshold manager        (GitHub binary)
#
# The DNF packages are declared in DNF_PACKAGES in common.sh so the packages
# phase installs them.  The three binary releases are downloaded from pinned
# upstream releases, SHA-256 verified, and installed under ~/.local/bin — the
# same pattern used by the device-controls phase for wlctl and Bluetui.

readonly SYSTEM_TOOL_PACKAGES=(
  diskonaut
  powertop
)

# ── systemctl-tui ────────────────────────────────────────────────────
readonly SYSTEMCTL_TUI_VERSION="0.8.0"
readonly SYSTEMCTL_TUI_REPOSITORY="https://github.com/rgwood/systemctl-tui"
readonly SYSTEMCTL_TUI_BINARY="$HOME/.local/bin/systemctl-tui"

systemctl_tui_asset_name() {
  case "$(uname -m)" in
    x86_64)  printf 'systemctl-tui-x86_64-unknown-linux-musl.tar.gz\n' ;;
    aarch64) printf 'systemctl-tui-aarch64-unknown-linux-musl.tar.gz\n' ;;
    *) return 1 ;;
  esac
}

systemctl_tui_expected_sha256() {
  case "$(uname -m)" in
    x86_64)  printf 'a3c069fde82b201f46c42009e50edbb0e3c7c7482d4eb6a12d6ef6b4dab5c0c4\n' ;;
    aarch64) printf '34397225c32f49ab25fa9bd5d735c2675fd2503916fe82dd22ac20847fad31f7\n' ;;
    *) return 1 ;;
  esac
}

systemctl_tui_binary_valid() {
  local expected_sha256
  expected_sha256="$(systemctl_tui_expected_sha256)" || return 1
  [[ -x "$SYSTEMCTL_TUI_BINARY" ]] &&
    printf '%s  %s\n' "$expected_sha256" "$SYSTEMCTL_TUI_BINARY" |
      sha256sum --check --status
}

install_systemctl_tui() {
  local asset_name expected_sha256 url
  asset_name="$(systemctl_tui_asset_name)" ||
    die "systemctl-tui $SYSTEMCTL_TUI_VERSION supports x86_64 and aarch64; found $(uname -m)"
  expected_sha256="$(systemctl_tui_expected_sha256)"
  url="$SYSTEMCTL_TUI_REPOSITORY/releases/download/v$SYSTEMCTL_TUI_VERSION/$asset_name"

  if systemctl_tui_binary_valid; then
    log "systemctl-tui $SYSTEMCTL_TUI_VERSION already installed and verified"
    return
  fi

  if [[ -e "$SYSTEMCTL_TUI_BINARY" ]]; then
    die "$SYSTEMCTL_TUI_BINARY exists but is not the pinned systemctl-tui $SYSTEMCTL_TUI_VERSION binary; move it aside and rerun the system-tools phase"
  fi

  if $DRY_RUN; then
    log "would download, verify, and install systemctl-tui $SYSTEMCTL_TUI_VERSION for $(uname -m)"
    printf '+ curl -fsSLo <archive> %q\n' "$url"
    printf '+ tar xzf <archive>\n'
    printf '+ verify SHA-256 %s for systemctl-tui\n' "$expected_sha256"
    printf '+ install -Dm0755 systemctl-tui %q\n' "$SYSTEMCTL_TUI_BINARY"
    return
  fi

  command -v curl >/dev/null 2>&1 || die 'curl is missing; run the packages phase first'

  local tmpdir
  tmpdir="$(mktemp -d)"
  curl -fsSLo "$tmpdir/archive.tar.gz" "$url"
  tar xzf "$tmpdir/archive.tar.gz" -C "$tmpdir"
  if ! printf '%s  %s\n' "$expected_sha256" "$tmpdir/systemctl-tui" |
    sha256sum --check --status; then
    die "systemctl-tui $SYSTEMCTL_TUI_VERSION failed SHA-256 verification; downloaded artifacts retained at $tmpdir"
  fi

  run install -Dm0755 "$tmpdir/systemctl-tui" "$SYSTEMCTL_TUI_BINARY"
  rm -rf -- "$tmpdir"
  systemctl_tui_binary_valid || die "systemctl-tui installation did not produce the expected binary: $SYSTEMCTL_TUI_BINARY"
  log "installed and verified systemctl-tui $SYSTEMCTL_TUI_VERSION at $SYSTEMCTL_TUI_BINARY"
}

# ── bandwhich ────────────────────────────────────────────────────────
readonly BANDWHICH_VERSION="0.23.1"
readonly BANDWHICH_REPOSITORY="https://github.com/imsnif/bandwhich"
readonly BANDWHICH_BINARY="$HOME/.local/bin/bandwhich"

bandwhich_asset_name() {
  case "$(uname -m)" in
    x86_64)  printf 'bandwhich-v%s-x86_64-unknown-linux-musl.tar.gz\n' "$BANDWHICH_VERSION" ;;
    aarch64) printf 'bandwhich-v%s-aarch64-unknown-linux-musl.tar.gz\n' "$BANDWHICH_VERSION" ;;
    *) return 1 ;;
  esac
}

bandwhich_expected_sha256() {
  case "$(uname -m)" in
    x86_64)  printf 'cc64d0a37e599f52b08572c472429cbc37d10a32d4bf6ece72cd48cac58dc857\n' ;;
    aarch64) printf 'ab473b1d33d5c24440c12874008dd8dbd33419e07b4957ee901349dc0de6b5a5\n' ;;
    *) return 1 ;;
  esac
}

bandwhich_binary_valid() {
  local expected_sha256
  expected_sha256="$(bandwhich_expected_sha256)" || return 1
  [[ -x "$BANDWHICH_BINARY" ]] &&
    printf '%s  %s\n' "$expected_sha256" "$BANDWHICH_BINARY" |
      sha256sum --check --status
}

install_bandwhich() {
  local asset_name expected_sha256 url
  asset_name="$(bandwhich_asset_name)" ||
    die "bandwhich $BANDWHICH_VERSION supports x86_64 and aarch64; found $(uname -m)"
  expected_sha256="$(bandwhich_expected_sha256)"
  url="$BANDWHICH_REPOSITORY/releases/download/v$BANDWHICH_VERSION/$asset_name"

  if bandwhich_binary_valid; then
    log "bandwhich $BANDWHICH_VERSION already installed and verified"
    return
  fi

  if [[ -e "$BANDWHICH_BINARY" ]]; then
    die "$BANDWHICH_BINARY exists but is not the pinned bandwhich $BANDWHICH_VERSION binary; move it aside and rerun the system-tools phase"
  fi

  if $DRY_RUN; then
    log "would download, verify, and install bandwhich $BANDWHICH_VERSION for $(uname -m)"
    printf '+ curl -fsSLo <archive> %q\n' "$url"
    printf '+ tar xzf <archive>\n'
    printf '+ verify SHA-256 %s for bandwhich\n' "$expected_sha256"
    printf '+ install -Dm0755 bandwhich %q\n' "$BANDWHICH_BINARY"
    return
  fi

  command -v curl >/dev/null 2>&1 || die 'curl is missing; run the packages phase first'

  local tmpdir
  tmpdir="$(mktemp -d)"
  curl -fsSLo "$tmpdir/archive.tar.gz" "$url"
  tar xzf "$tmpdir/archive.tar.gz" -C "$tmpdir"
  if ! printf '%s  %s\n' "$expected_sha256" "$tmpdir/bandwhich" |
    sha256sum --check --status; then
    die "bandwhich $BANDWHICH_VERSION failed SHA-256 verification; downloaded artifacts retained at $tmpdir"
  fi

  run install -Dm0755 "$tmpdir/bandwhich" "$BANDWHICH_BINARY"
  rm -rf -- "$tmpdir"
  bandwhich_binary_valid || die "bandwhich installation did not produce the expected binary: $BANDWHICH_BINARY"
  log "installed and verified bandwhich $BANDWHICH_VERSION at $BANDWHICH_BINARY"
}

# ── batctl (battery charge threshold manager) ────────────────────────
readonly BATCTL_VERSION="2026.3.13"
readonly BATCTL_REPOSITORY="https://github.com/Ooooze/batctl"
readonly BATCTL_BINARY="$HOME/.local/bin/batctl"

batctl_asset_name() {
  case "$(uname -m)" in
    x86_64)  printf 'batctl-%s-linux-x86_64.tar.gz\n' "$BATCTL_VERSION" ;;
    aarch64) printf 'batctl-%s-linux-aarch64.tar.gz\n' "$BATCTL_VERSION" ;;
    *) return 1 ;;
  esac
}

batctl_expected_sha256() {
  case "$(uname -m)" in
    x86_64)  printf 'dd77798092ee284f9736b0299027ce38992942ba9e2ca6d73bbb4746d2230153\n' ;;
    aarch64) printf 'e73c4db924a47b20d293b6ff54e84a8f6ff2b197d40791852034cfc24702f989\n' ;;
    *) return 1 ;;
  esac
}

batctl_binary_valid() {
  local expected_sha256
  expected_sha256="$(batctl_expected_sha256)" || return 1
  [[ -x "$BATCTL_BINARY" ]] &&
    printf '%s  %s\n' "$expected_sha256" "$BATCTL_BINARY" |
      sha256sum --check --status
}

install_batctl() {
  local asset_name expected_sha256 url
  asset_name="$(batctl_asset_name)" ||
    die "batctl $BATCTL_VERSION supports x86_64 and aarch64; found $(uname -m)"
  expected_sha256="$(batctl_expected_sha256)"
  url="$BATCTL_REPOSITORY/releases/download/v$BATCTL_VERSION/$asset_name"

  if batctl_binary_valid; then
    log "batctl $BATCTL_VERSION already installed and verified"
    return
  fi

  if [[ -e "$BATCTL_BINARY" ]]; then
    die "$BATCTL_BINARY exists but is not the pinned batctl $BATCTL_VERSION binary; move it aside and rerun the system-tools phase"
  fi

  if $DRY_RUN; then
    log "would download, verify, and install batctl $BATCTL_VERSION for $(uname -m)"
    printf '+ curl -fsSLo <archive> %q\n' "$url"
    printf '+ tar xzf <archive>\n'
    printf '+ verify SHA-256 %s for batctl\n' "$expected_sha256"
    printf '+ install -Dm0755 batctl %q\n' "$BATCTL_BINARY"
    return
  fi

  command -v curl >/dev/null 2>&1 || die 'curl is missing; run the packages phase first'

  local tmpdir
  tmpdir="$(mktemp -d)"
  curl -fsSLo "$tmpdir/archive.tar.gz" "$url"
  tar xzf "$tmpdir/archive.tar.gz" -C "$tmpdir"
  if ! printf '%s  %s\n' "$expected_sha256" "$tmpdir/batctl" |
    sha256sum --check --status; then
    die "batctl $BATCTL_VERSION failed SHA-256 verification; downloaded artifacts retained at $tmpdir"
  fi

  run install -Dm0755 "$tmpdir/batctl" "$BATCTL_BINARY"
  rm -rf -- "$tmpdir"
  batctl_binary_valid || die "batctl installation did not produce the expected binary: $BATCTL_BINARY"
  log "installed and verified batctl $BATCTL_VERSION at $BATCTL_BINARY"
}

# ── Phase entry point ────────────────────────────────────────────────
install_system_tools() {
  local -a missing=()
  local package

  for package in "${SYSTEM_TOOL_PACKAGES[@]}"; do
    package_installed "$package" || missing+=("$package")
  done

  if ((${#missing[@]} == 0)); then
    log 'Fedora system-tool packages already installed'
  else
    log "installing Fedora system-tool packages: ${missing[*]}"
    local -a command=(sudo dnf install)
    $ASSUME_YES && command+=(--assumeyes)
    run "${command[@]}" "${missing[@]}"
  fi

  install_systemctl_tui
  install_bandwhich
  install_batctl
}

show_system_tools_status() {
  printf 'System tools:\n'
  local package
  for package in "${SYSTEM_TOOL_PACKAGES[@]}"; do
    if package_installed "$package"; then
      printf '  [ok]       %s\n' "$package"
    else
      printf '  [missing]  %s\n' "$package"
    fi
  done

  if systemctl_tui_binary_valid; then
    printf '  [pinned]   systemctl-tui %s\n' "$SYSTEMCTL_TUI_VERSION"
  elif [[ -e "$SYSTEMCTL_TUI_BINARY" ]]; then
    printf '  [local]    %s (not the pinned artifact)\n' "$SYSTEMCTL_TUI_BINARY"
  else
    printf '  [missing]  systemctl-tui %s\n' "$SYSTEMCTL_TUI_VERSION"
  fi

  if bandwhich_binary_valid; then
    printf '  [pinned]   bandwhich %s\n' "$BANDWHICH_VERSION"
  elif [[ -e "$BANDWHICH_BINARY" ]]; then
    printf '  [local]    %s (not the pinned artifact)\n' "$BANDWHICH_BINARY"
  else
    printf '  [missing]  bandwhich %s\n' "$BANDWHICH_VERSION"
  fi

  if batctl_binary_valid; then
    printf '  [pinned]   batctl %s\n' "$BATCTL_VERSION"
  elif [[ -e "$BATCTL_BINARY" ]]; then
    printf '  [local]    %s (not the pinned artifact)\n' "$BATCTL_BINARY"
  else
    printf '  [missing]  batctl %s\n' "$BATCTL_VERSION"
  fi
}