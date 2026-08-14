#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

require_export
require_replacement_packages

failed=false

check_active() {
  local service="$1"
  if systemctl --user --quiet is-active "$service"; then
    printf '  [active]   %s\n' "$service"
  else
    printf '  [inactive] %s\n' "$service"
    failed=true
  fi
}

printf 'Bare-niri services:\n'
check_active niri.service
check_active mako.service
check_active swayidle.service
check_active lxqt-policykit-agent.service

if systemctl --user --quiet is-active dms.service; then
  printf '  [failed]   dms.service is still active\n'
  failed=true
else
  printf '  [clear]    dms.service is inactive\n'
fi

if [[ -L "$HOME/.config/systemd/user/niri.service.wants/dms.service" ]]; then
  printf '  [failed]   dms.service is still attached to niri\n'
  failed=true
else
  printf '  [clear]    dms.service is detached from niri\n'
fi

if $failed; then
  die 'the service-level bare-niri baseline is not ready'
fi

cat <<'CHECKLIST'

Service checks passed. Validate these manually before removing DMS:
  - Mod+Space opens Fuzzel.
  - Mod+Shift+L locks and unlocks the session.
  - notify-send "Bare niri test" "Mako is working" displays a notification.
  - pkexec /usr/bin/id displays a graphical authentication prompt.
  - terminal, browser, files, portals, Xwayland, screenshots, clipboard,
    media keys, and brightness controls work.
CHECKLIST
