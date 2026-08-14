#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

usage() {
  printf 'Usage: %s [--dry-run] [--yes]\n' "${0##*/}"
}

if ! parse_mutation_options "$@"; then
  usage
  exit 0
fi

require_export

for package in dms dms-cli dms-greeter; do
  package_installed "$package" && die "$package is still installed"
done
systemctl --user --quiet is-active dms.service && die 'dms.service is still active'

if [[ -r /etc/greetd/config.toml ]] && rg -q 'dms-greeter|\bdms\b' /etc/greetd/config.toml; then
  die '/etc/greetd/config.toml still references DMS'
fi

readonly -a DMS_USER_PATHS=(
  "$HOME/.config/DankMaterialShell"
  "$HOME/.local/state/DankMaterialShell"
  "$HOME/.cache/DankMaterialShell"
  "$HOME/.config/niri/dms"
  "$HOME/.config/systemd/user/niri.service.wants/dms.service"
)

printf 'Exact user paths selected for removal:\n'
for path in "${DMS_USER_PATHS[@]}"; do
  printf '  %s\n' "$path"
done

if ! confirm 'Remove only these exported DMS user paths'; then
  die 'DMS user-state cleanup cancelled'
fi

for path in "${DMS_USER_PATHS[@]}"; do
  if [[ -e "$path" || -L "$path" ]]; then
    run rm -rf -- "$path"
  else
    log "$path is already absent"
  fi
done

run systemctl --user daemon-reload
log 'User-state cleanup complete.'
log 'Greeter cache, repositories, group membership, and ACLs remain separate manual steps.'
