# Supervised DMS uninstall guide

This command-driven runbook completes the one-time transition from DMS to the
repository-owned bare-niri baseline. Do not skip a reboot or continue past a
failed check.

Keep the migration export at
`~/.local/state/dotfiles-fedora/migrations/dms-20260813` until the final reboot
passes. Run repository commands from the checkout:

```bash
cd ~/.local/share/dotfiles-fedora
```

## 1. Confirm a clean, recoverable repository state

```bash
git status --short
git log -1 --oneline --decorate
./scripts/dms-transition/status.sh
./scripts/dms-transition/detach.sh --dry-run --yes
```

`git status --short` must print nothing. The status helper must report the
export, replacement packages, and replacement service attachments as present.

## 2. Establish a recovery login on TTY3

From the graphical session on TTY1, press `Ctrl+Alt+F3` or
`Ctrl+Alt+Fn+F3`. At the text prompt, enter the normal username and password,
then run:

```bash
tty
sudo -v
```

`tty` must print `/dev/tty3`, and `sudo -v` must succeed. Leave that shell open
and press `Ctrl+Alt+F1` or `Ctrl+Alt+Fn+F1` to return to the graphical session.

Do not continue without the authenticated TTY3 shell.

## 3. Detach DMS from future niri sessions

In an Alacritty window on TTY1, run:

```bash
cd ~/.local/share/dotfiles-fedora
./scripts/dms-transition/detach.sh
./scripts/dms-transition/status.sh
```

Answer `y` only because TTY3 is already authenticated. The second command must
show `dms.service` as disabled and detached; it may remain active until logout.

## 4. End the DMS-backed session and start bare niri

From Alacritty on TTY1, request a normal niri logout:

```bash
niri msg action quit
```

Press Enter when niri asks for confirmation. Switch to the existing recovery
shell with `Ctrl+Alt+F3` or `Ctrl+Alt+Fn+F3`, then run:

```bash
sudo systemctl stop greetd.service
systemctl is-active greetd.service
niri-session
```

`systemctl is-active` must print `inactive`. `niri-session` occupies TTY3 until
the graphical session exits; once niri appears, open Alacritty with `Mod+Return`
for the next step.

## 5. Validate the first bare-niri session

Run the service-level checks in Alacritty:

```bash
cd ~/.local/share/dotfiles-fedora
./scripts/dms-transition/verify-baseline.sh
systemctl --user --no-pager --full status \
  niri.service \
  mako.service \
  swayidle.service \
  lxqt-policykit-agent.service
```

All four services must be active and `dms.service` must be inactive. Perform the
visible tests with these exact actions:

```bash
notify-send "Bare niri test" "Mako is working"
pkexec /usr/bin/id
printf 'bare-niri-clipboard-test' | wl-copy
wl-paste
brightnessctl --class=backlight get
wpctl status
pgrep -a xwayland-satellite
systemctl --user --no-pager --full status \
  xdg-desktop-portal.service \
  xdg-desktop-portal-gnome.service \
  xdg-desktop-portal-gtk.service
```

Expected visible results:

- `Mod+Space` opens Fuzzel; press Escape to close it.
- `notify-send` produces a Mako notification.
- `pkexec` produces an LXQt PolicyKit prompt and prints root identity after
  authentication.
- `wl-paste` prints `bare-niri-clipboard-test`.
- Brightness, PipeWire, Xwayland Satellite, and portal commands report healthy
  state.
- `Mod+Shift+L` opens Swaylock and the normal password unlocks it.
- `Mod+B`, `Mod+E`, media keys, brightness keys, and Print each perform their
  configured action.

To include suspend/resume in this checkpoint, save work and run:

```bash
systemctl suspend
```

The session must be locked after resume. Skip this command if suspend testing is
being deferred; do not treat an untested suspend path as validated.

## 6. Recover if the first bare-session test fails

Exit bare niri from Alacritty:

```bash
niri msg action quit
```

Press Enter to confirm. Back at the TTY3 shell, restore DMS startup and greetd:

```bash
systemctl --user add-wants niri.service dms.service
systemctl --user enable dms.service
systemctl --user daemon-reload
sudo systemctl start greetd.service
```

Press `Ctrl+Alt+F1` or `Ctrl+Alt+Fn+F1` to return to the greeter. Stop the
runbook here until the bare-session failure is fixed.

## 7. Exit a successful test and uninstall DMS Greeter integration

After all Step 5 tests pass, exit bare niri from Alacritty:

```bash
niri msg action quit
```

Press Enter to confirm. At the returned TTY3 shell, run the vendor-supported
greeter removal while the DMS CLI still exists:

```bash
dms greeter status
dms greeter uninstall --yes
systemctl is-enabled greetd.service || true
systemctl is-active greetd.service || true
systemctl get-default
systemctl status display-manager.service --no-pager || true
```

Then establish the temporary text-login boot explicitly:

```bash
sudo systemctl disable greetd.service
sudo systemctl set-default multi-user.target
systemctl is-enabled greetd.service || true
systemctl get-default
```

The final two commands must report `disabled` and `multi-user.target`. Do not
remove DMS packages before the reboot checkpoint.

## 8. Reboot and prove the TTY recovery path

```bash
sudo reboot
```

At the text login prompt, enter the normal username and password, then run:

```bash
tty
systemctl get-default
niri-session
```

`tty` must report a real virtual terminal and the boot target must be
`multi-user.target`. Once niri appears, open Alacritty with `Mod+Return` and run:

```bash
cd ~/.local/share/dotfiles-fedora
./scripts/dms-transition/verify-baseline.sh
notify-send "Reboot test" "Bare niri survived reboot"
pkexec /usr/bin/id
```

Also open Fuzzel with `Mod+Space` and lock/unlock with `Mod+Shift+L`. This reboot
and validation are the package-removal gate.

## 9. Preview the DMS package transaction

From Alacritty in the proven bare session, run:

```bash
cd ~/.local/share/dotfiles-fedora
./scripts/dms-transition/preview-removal.sh
```

Read the DNF transaction and confirm it retains all of these packages:

```bash
rpm -q \
  niri \
  fuzzel \
  mako \
  swayidle \
  swaylock \
  lxqt-policykit \
  xdg-desktop-portal \
  xdg-desktop-portal-gnome \
  xdg-desktop-portal-gtk \
  xwayland-satellite
```

Every `rpm -q` line must show an installed version.

## 10. Remove the DMS packages

Run the real transaction and answer `y` only if it matches the reviewed preview:

```bash
sudo dnf remove dms dms-cli dms-greeter
rpm -q dms dms-cli dms-greeter || true
```

The second command must report that all three packages are not installed.

## 11. Remove Quickshell and greetd from the clean baseline

Preview both transactions:

```bash
sudo dnf remove --assumeno quickshell
sudo dnf remove --assumeno greetd greetd-selinux
```

Confirm each preview retains the protected packages listed in Step 9, then run:

```bash
sudo dnf remove quickshell
sudo dnf remove greetd greetd-selinux
rpm -q quickshell greetd greetd-selinux || true
```

All three packages must report as not installed. Quickshell will be added back
through the repository during the custom-shell ticket.

## 12. Disable the DMS repositories

```bash
sudo dnf copr disable avengemedia/dms
sudo dnf copr disable avengemedia/danklinux
dnf copr list | rg 'avengemedia/(dms|danklinux)' || true
```

The final command must print nothing.

## 13. Remove exported DMS user state

Preview the exact paths and then run the guarded cleanup:

```bash
cd ~/.local/share/dotfiles-fedora
./scripts/dms-transition/cleanup-user-state.sh --dry-run --yes
./scripts/dms-transition/cleanup-user-state.sh
```

Confirm the prompt only after comparing it with the dry-run output. Verify the
known paths are absent while the migration export remains:

```bash
for path in \
  "$HOME/.config/DankMaterialShell" \
  "$HOME/.local/state/DankMaterialShell" \
  "$HOME/.cache/DankMaterialShell" \
  "$HOME/.config/niri/dms" \
  "$HOME/.config/systemd/user/niri.service.wants/dms.service"; do
  [[ ! -e "$path" && ! -L "$path" ]] || printf 'still present: %s\n' "$path"
done
test -d "$HOME/.local/state/dotfiles-fedora/migrations/dms-20260813"
```

The loop must print nothing and the final `test` must succeed.

## 14. Remove confirmed system-level greeter remnants

Inspect the exact paths:

```bash
sudo ls -la /var/cache/dms-greeter 2>/dev/null || true
sudo ls -la /etc/greetd 2>/dev/null || true
sudo ls -la /etc/greetd/niri 2>/dev/null || true
```

If the output confirms that these exact paths remain and are DMS-owned, remove
only them:

```bash
sudo rm -rf -- /var/cache/dms-greeter
sudo rm -f -- /etc/greetd/niri/dms.kdl
sudo test ! -e /var/cache/dms-greeter
sudo test ! -e /etc/greetd/niri/dms.kdl
```

Do not remove `/etc/greetd` as a whole.

## 15. Reverse DMS Greeter ACL and group changes

Ensure the ACL inspection tools exist and print only named greeter entries:

```bash
command -v getfacl >/dev/null || sudo dnf install acl
getfacl -cp \
  "$HOME" \
  "$HOME/.config" \
  "$HOME/.cache" \
  "$HOME/.local" \
  "$HOME/.local/state" | rg '^(# file:|user:greeter:)'
```

For each exact directory that displayed `user:greeter:...`, remove only that
named entry; the conditional loop skips directories without one:

```bash
for path in \
  "$HOME" \
  "$HOME/.config" \
  "$HOME/.cache" \
  "$HOME/.local" \
  "$HOME/.local/state"; do
  if getfacl -cp "$path" | rg -q '^user:greeter:'; then
    setfacl -x u:greeter "$path"
  fi
done
```

Inspect and remove the current user's greeter-group membership:

```bash
id -nG | tr ' ' '\n' | rg '^greeter$' || true
sudo gpasswd -d "$(id -un)" greeter
id -nG | tr ' ' '\n' | rg '^greeter$' || true
```

The last command must print nothing. Never recursively reset ownership or
permissions across the home directory.

## 16. Run final DMS absence checks

```bash
cd ~/.local/share/dotfiles-fedora
./scripts/dms-transition/status.sh
rpm -q dms dms-cli dms-greeter || true
pgrep -a -f 'dms|DankMaterialShell' || true
systemctl --user is-active dms.service || true
systemctl --user is-enabled dms.service || true
dnf copr list | rg 'avengemedia/(dms|danklinux)' || true
rg -n -i 'dms|dms-greeter|DankMaterialShell' \
  "$HOME/.config/niri" \
  "$HOME/.config/systemd/user" \
  /etc/greetd 2>/dev/null || true
```

Expected results are no DMS packages, process, active/enabled service, niri
attachment, enabled DMS COPR, DMS-owned greetd configuration, or DMS user/cache
directory. The transition status may still mention the preserved export and
the names of absent components; those are informational rather than remnants.

## 17. Perform the final reboot and smoke test

Exit niri from Alacritty:

```bash
niri msg action quit
```

Press Enter to confirm, then reboot from the returned TTY:

```bash
sudo reboot
```

Log in at the text prompt and run:

```bash
niri-session
```

Open Alacritty with `Mod+Return`, then run the final checks:

```bash
cd ~/.local/share/dotfiles-fedora
./scripts/dms-transition/verify-baseline.sh
notify-send "Final test" "DMS-free niri is ready"
pkexec /usr/bin/id
```

Open Fuzzel with `Mod+Space`, lock/unlock with `Mod+Shift+L`, and confirm the
browser, file manager, portals, clipboard, media keys, brightness keys, and
Xwayland still work. Ticket 4 is complete only after this smoke test passes.
