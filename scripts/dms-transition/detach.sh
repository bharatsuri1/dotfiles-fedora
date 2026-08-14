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
require_replacement_packages

for service in mako.service swayidle.service lxqt-policykit-agent.service; do
  [[ -L "$HOME/.config/systemd/user/niri.service.wants/$service" ]] ||
    die "replacement service is not attached to niri: $service"
done

log 'This changes only future session startup; it will not stop the current DMS process.'
if ! confirm 'Is a second TTY open and logged in as your recovery path'; then
  die 'DMS detachment cancelled'
fi

run systemctl --user disable dms.service
readonly dms_want="$HOME/.config/systemd/user/niri.service.wants/dms.service"
if [[ -L "$dms_want" ]]; then
  run unlink "$dms_want"
fi
run systemctl --user daemon-reload

log 'DMS is detached for the next session.'
log 'Manually log out, stop greetd from the recovery TTY, and run niri-session.'
