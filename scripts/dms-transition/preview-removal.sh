#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

require_export
require_replacement_packages

systemctl --user --quiet is-active dms.service &&
  die 'dms.service is active; prove the bare session before previewing removal'
[[ ! -L "$HOME/.config/systemd/user/niri.service.wants/dms.service" ]] ||
  die 'dms.service is still attached to niri'

log 'Previewing only; DNF will abort without changing packages.'
set +e
sudo dnf remove --assumeno dms dms-cli dms-greeter
dnf_status=$?
set -e

if ((dnf_status == 0)); then
  log 'DNF completed the preview without reporting an abort.'
else
  log "DNF preview exited with status $dnf_status; this is expected when --assumeno declines the transaction."
fi

cat <<'CHECKLIST'

Before manually accepting removal, confirm the transaction retains:
  niri, fuzzel, mako, swayidle, swaylock, lxqt-policykit,
  xdg-desktop-portal, xdg-desktop-portal-gnome,
  xdg-desktop-portal-gtk, and xwayland-satellite.
CHECKLIST
