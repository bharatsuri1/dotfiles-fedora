#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

printf 'Migration export:\n'
if [[ -d "$DMS_EXPORT_DIR" ]]; then
  printf '  [ok]      %s\n' "$DMS_EXPORT_DIR"
else
  printf '  [missing] %s\n' "$DMS_EXPORT_DIR"
fi

printf 'Packages:\n'
for package in dms dms-cli dms-greeter quickshell greetd niri fuzzel mako swayidle swaylock lxqt-policykit xwayland-satellite; do
  if package_installed "$package"; then
    printf '  [installed] %s\n' "$package"
  else
    printf '  [absent]    %s\n' "$package"
  fi
done

printf 'User services:\n'
for service in dms.service mako.service swayidle.service lxqt-policykit-agent.service niri.service; do
  printf '  %-30s active=%-8s enabled=%s\n' \
    "$service" \
    "$(systemctl --user is-active "$service" 2>/dev/null || true)" \
    "$(systemctl --user is-enabled "$service" 2>/dev/null || true)"
done

printf 'Niri wants:\n'
for service in dms.service mako.service swayidle.service lxqt-policykit-agent.service; do
  if [[ -L "$HOME/.config/systemd/user/niri.service.wants/$service" ]]; then
    printf '  [attached] %s\n' "$service"
  else
    printf '  [detached] %s\n' "$service"
  fi
done

printf 'Graphical login:\n'
printf '  default-target=%s\n' "$(systemctl get-default 2>/dev/null || true)"
printf '  greetd-active=%s\n' "$(systemctl is-active greetd.service 2>/dev/null || true)"
printf '  greetd-enabled=%s\n' "$(systemctl is-enabled greetd.service 2>/dev/null || true)"
if [[ -r /etc/greetd/config.toml ]] && rg -q 'dms-greeter|\bdms\b' /etc/greetd/config.toml; then
  printf '  [DMS-owned] /etc/greetd/config.toml\n'
else
  printf '  [clear]     /etc/greetd/config.toml\n'
fi

printf 'COPRs:\n'
dnf copr list 2>/dev/null | rg 'avengemedia/(dms|danklinux)' || printf '  [clear] no DMS COPRs enabled\n'

printf 'Known DMS paths:\n'
for path in \
  "$HOME/.config/DankMaterialShell" \
  "$HOME/.local/state/DankMaterialShell" \
  "$HOME/.cache/DankMaterialShell" \
  "$HOME/.config/niri/dms" \
  "$HOME/.config/systemd/user/niri.service.wants/dms.service" \
  /var/cache/dms-greeter; do
  if [[ -e "$path" || -L "$path" ]]; then
    printf '  [present] %s\n' "$path"
  else
    printf '  [absent]  %s\n' "$path"
  fi
done

printf 'Greeter security state:\n'
if id -nG "$(id -un)" | tr ' ' '\n' | rg -qx greeter; then
  printf '  [member] user belongs to greeter group\n'
else
  printf '  [clear]  user is not in greeter group\n'
fi
if command -v getfacl >/dev/null 2>&1; then
  getfacl -cp "$HOME" "$HOME/.config" "$HOME/.cache" "$HOME/.local/state" 2>/dev/null |
    rg '^(user:greeter:|# file:)' || true
fi
