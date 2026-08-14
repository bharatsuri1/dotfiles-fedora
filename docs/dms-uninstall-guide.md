# Supervised DMS uninstall guide

This guide completes the one-time transition from DMS to the repository-owned
bare-niri baseline. It intentionally separates observable recovery boundaries
from scripted checks. Do not skip a reboot or continue past a failed validation.

The migration export must remain available at
`~/.local/state/dotfiles-fedora/migrations/dms-20260813` until the final reboot
and absence checks pass.

Run repository commands from `~/.local/share/dotfiles-fedora` unless stated
otherwise.

## 1. Confirm a clean, recoverable repository state

Commit and push the repository before changing the live session. Then inspect
the current migration state:

```bash
./scripts/dms-transition/status.sh
./scripts/dms-transition/detach.sh --dry-run
```

Confirm that the migration export exists; niri, Fuzzel, Mako, Swayidle,
Swaylock, LXQt PolicyKit, and Xwayland Satellite are installed; and the three
replacement services are attached to `niri.service`.

## 2. Establish a recovery TTY

1. Press `Ctrl+Alt+F3`, or `Ctrl+Alt+Fn+F3` on laptops that require the `Fn`
   modifier.
2. Log in with the normal user account.
3. Confirm administrative access:

   ```bash
   sudo -v
   ```

4. Keep this TTY logged in.
5. Return to the graphical session using the function key on which it is
   running.

Do not continue without an authenticated recovery TTY.

## 3. Detach DMS from future sessions

From a terminal in the current graphical session, run:

```bash
./scripts/dms-transition/detach.sh
./scripts/dms-transition/status.sh
```

The helper removes the niri-to-DMS dependency and disables `dms.service`
without stopping it. DMS may remain active until logout, but it must show as
detached and disabled for the next session.

## 4. Start the first bare-niri session

1. Log out of the graphical session.
2. Return to the authenticated recovery TTY.
3. Stop DMS Greeter so it does not reclaim the graphics seat:

   ```bash
   sudo systemctl stop greetd.service
   ```

4. Start the independent session:

   ```bash
   niri-session
   ```

## 5. Validate the bare session

Inside the new niri session, run:

```bash
cd ~/.local/share/dotfiles-fedora
./scripts/dms-transition/verify-baseline.sh
```

Then verify the visible behavior that a script cannot prove:

1. `Mod+Space` opens Fuzzel.
2. `Mod+Shift+L` locks and unlocks the session.
3. Mako displays a notification:

   ```bash
   notify-send "Bare niri test" "Mako is working"
   ```

4. LXQt PolicyKit displays a graphical authentication prompt:

   ```bash
   pkexec /usr/bin/id
   ```

5. Test Alacritty, Chromium, Nautilus, audio and media keys, brightness keys,
   screenshots, clipboard copy/paste, portal file dialogs, and an Xwayland
   application.
6. Test suspend and resume only when ready to include it in this checkpoint.

Do not remove packages unless the bare session is usable.

## 6. Recover if the first test fails

Log out of niri with `Mod+Shift+E` to return to the TTY. If the baseline failed,
restore the previous startup path before investigating:

```bash
systemctl --user add-wants niri.service dms.service
systemctl --user enable dms.service
sudo systemctl start greetd.service
```

Stop here until the failure is resolved.

## 7. Uninstall DMS Greeter integration

After a successful bare-session test, return to the TTY with `Mod+Shift+E`.
While the DMS CLI still exists, inspect and invoke its supported uninstall path:

```bash
dms greeter status
dms greeter uninstall --yes
```

Inspect the resulting login state:

```bash
systemctl is-enabled greetd.service
systemctl is-active greetd.service
systemctl get-default
systemctl status display-manager.service --no-pager
```

Establish the temporary text-login baseline explicitly:

```bash
sudo systemctl disable greetd.service
sudo systemctl set-default multi-user.target
```

Do not uninstall DMS packages before the reboot checkpoint.

## 8. Reboot and prove recovery

```bash
sudo reboot
```

After reboot, confirm that the machine reaches a text login. Log in, run
`niri-session`, and repeat:

```bash
cd ~/.local/share/dotfiles-fedora
./scripts/dms-transition/verify-baseline.sh
```

Briefly retest Fuzzel, Mako, Swaylock, and the PolicyKit prompt. This reboot is
the package-removal gate.

## 9. Preview DMS package removal

Run:

```bash
./scripts/dms-transition/preview-removal.sh
```

The proposed transaction must retain:

```text
niri
fuzzel
mako
swayidle
swaylock
lxqt-policykit
xdg-desktop-portal
xdg-desktop-portal-gnome
xdg-desktop-portal-gtk
xwayland-satellite
```

## 10. Remove DMS packages

After approving the preview, run:

```bash
sudo dnf remove dms dms-cli dms-greeter
```

Review the transaction again before accepting it. Then verify that all three
packages are absent:

```bash
rpm -q dms dms-cli dms-greeter
```

## 11. Remove temporary shell and login packages

Preview Quickshell and greetd separately:

```bash
sudo dnf remove --assumeno quickshell
sudo dnf remove --assumeno greetd greetd-selinux
```

For the cleanest baseline, remove Quickshell now and add it back through the
repository in the custom-shell ticket. Remove greetd only after DMS Greeter
uninstall succeeded and TTY boot was proven:

```bash
sudo dnf remove quickshell
sudo dnf remove greetd greetd-selinux
```

Accept each transaction only if it retains the protected bare-niri packages.

## 12. Disable DMS repositories

After no retained package needs them:

```bash
sudo dnf copr disable avengemedia/dms
sudo dnf copr disable avengemedia/danklinux
dnf copr list
```

Neither AvengeMedia repository should remain enabled.

## 13. Clean exported DMS user state

Preview the exact paths first:

```bash
./scripts/dms-transition/cleanup-user-state.sh --dry-run
```

Then remove them:

```bash
./scripts/dms-transition/cleanup-user-state.sh
```

The helper removes only:

```text
~/.config/DankMaterialShell
~/.local/state/DankMaterialShell
~/.cache/DankMaterialShell
~/.config/niri/dms
~/.config/systemd/user/niri.service.wants/dms.service
```

It does not remove the migration export.

## 14. Review system-level greeter remnants

Inspect exact paths before deleting anything:

```bash
sudo ls -la /var/cache/dms-greeter
sudo ls -la /etc/greetd
sudo ls -la /etc/greetd/niri
```

Only if the remaining paths are confirmed DMS-owned, remove them explicitly:

```bash
sudo rm -rf -- /var/cache/dms-greeter
sudo rm -f -- /etc/greetd/niri/dms.kdl
```

Do not broadly remove `/etc/greetd` unless every remaining file has been
reviewed and is obsolete.

## 15. Reverse DMS Greeter security changes

Inspect named ACLs first:

```bash
getfacl -p \
  "$HOME" \
  "$HOME/.config" \
  "$HOME/.cache" \
  "$HOME/.local" \
  "$HOME/.local/state"
```

If `getfacl` is unavailable, install Fedora's `acl` package before continuing.
Remove only explicit `greeter` ACL entries that DMS added:

```bash
setfacl -x u:greeter "$HOME"
setfacl -x u:greeter "$HOME/.config"
setfacl -x u:greeter "$HOME/.cache"
setfacl -x u:greeter "$HOME/.local"
setfacl -x u:greeter "$HOME/.local/state"
```

If greetd and DMS Greeter are gone, remove the user's greeter-group membership:

```bash
sudo gpasswd -d "$(id -un)" greeter
```

Never recursively reset ownership or permissions across the home directory.

## 16. Run final absence checks

```bash
./scripts/dms-transition/status.sh
rpm -q dms dms-cli dms-greeter
pgrep -a -f 'dms|DankMaterialShell'
systemctl --user status dms.service
dnf copr list
rg -n -i 'dms|dms-greeter|DankMaterialShell' \
  ~/.config/niri \
  ~/.config/systemd/user \
  /etc/greetd 2>/dev/null
```

The expected state is:

- no DMS package, process, user service, or niri attachment;
- no DMS-owned greetd configuration or enabled DMS COPR;
- no DMS user/cache directory or greeter cache;
- the bare-niri services remain active and functional.

Some absence commands intentionally return a nonzero status when they find
nothing.

## 17. Perform the final reboot

```bash
sudo reboot
```

Log in from the TTY, start `niri-session`, and perform one final launcher,
notification, lock, PolicyKit, portal, and Xwayland test. After this succeeds,
Ticket 4 is complete and `scripts/dms-transition/` can be removed.
