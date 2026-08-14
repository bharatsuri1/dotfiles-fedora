#!/usr/bin/env bash

set -Eeuo pipefail

readonly DMS_EXPORT_DIR="${DMS_EXPORT_DIR:-$HOME/.local/state/dotfiles-fedora/migrations/dms-20260813}"

DRY_RUN=false
ASSUME_YES=false

log() {
  printf '==> %s\n' "$*"
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

run() {
  if $DRY_RUN; then
    printf '+ '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

confirm() {
  local prompt="$1"
  $ASSUME_YES && return 0

  local answer
  if [[ -r /dev/tty ]]; then
    read -r -p "$prompt [y/N] " answer </dev/tty
  else
    die 'confirmation requires a terminal; use --yes only after reviewing --dry-run output'
  fi
  [[ "$answer" == [yY] || "$answer" == [yY][eE][sS] ]]
}

parse_mutation_options() {
  while (($#)); do
    case "$1" in
      --dry-run) DRY_RUN=true ;;
      --yes|-y) ASSUME_YES=true ;;
      --help|-h) return 2 ;;
      *) die "unknown option: $1" ;;
    esac
    shift
  done
}

package_installed() {
  rpm -q "$1" >/dev/null 2>&1
}

require_export() {
  [[ -d "$DMS_EXPORT_DIR" ]] || die "DMS export is missing: $DMS_EXPORT_DIR"
  [[ -r "$DMS_EXPORT_DIR/config/settings.json" ]] ||
    die 'exported DMS settings are missing'
  [[ -r "$DMS_EXPORT_DIR/niri/outputs.kdl" ]] ||
    die 'exported DMS output configuration is missing'
}

require_replacement_packages() {
  local package
  for package in fuzzel lxqt-policykit mako niri swayidle swaylock xwayland-satellite; do
    package_installed "$package" || die "required replacement package is missing: $package"
  done
}
