# Fedora 44 ISO to laptop-setup

Linear path from the official Fedora 44 Everything netinst ISO to a TTY Custom
OS install with working Wi-Fi, then the repository bootstrap. This repository
does not own disk layout, encryption secrets, or Anaconda automation.

**Where each section runs** is marked. Destructive disk steps require you to
verify the target disk and backup state yourself.

Ongoing updates, removal, and rollback stay out of this guide (see issue
[#37](https://github.com/bharatsuri1/dotfiles-fedora/issues/37)). Desktop
session details live in the [README](../README.md).

## 1. Download and verify the ISO

Supported release: **Fedora 44 Everything** (network install), x86_64.

- ISO directory:
  <https://download.fedoraproject.org/pub/fedora/linux/releases/44/Everything/x86_64/iso/>
- Current image name pattern:
  `Fedora-Everything-netinst-x86_64-44-*.iso`
- Also download the matching `CHECKSUM` file from the same directory and verify
  with the official Fedora checksum instructions before writing media.

## 2. Create boot media

Use one supported method from Fedora's guide:

- <https://docs.fedoraproject.org/en-US/quick-docs/creating-and-using-a-live-installation-image/>

On another Linux machine, a typical write looks like:

```bash
sudo dd if=Fedora-Everything-netinst-x86_64-44-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

**Destructive.** Confirm `of=` is the USB device, not an internal disk
(`lsblk`, `wipefs` inspection first). Preserve any existing recovery media you
still need.

## 3. Boot the installer

1. Enter firmware boot menu and select the USB stick.
2. Prefer UEFI boot when the laptop uses UEFI.
3. Complete language and keyboard when prompted.

### Installer choices that matter

| Choice | Intended value |
| --- | --- |
| Software / environment | **Custom OS** (not Workstation, not Server, not a full desktop) |
| Networking | Connect Wi-Fi in the installer if offered; the live environment needs net for package install later |
| Storage | Your choice; encryption is supported |
| Disk selection | **Verify the exact internal target disk** before accepting destructive partitioning |
| Hostname, time zone | Set for this machine |
| User | Create an administrative (wheel) user you will use after first boot |

Custom OS deliberately omits most firmware and desktop stacks. On Intel Wi-Fi
hardware that worked in the installer, the installed system often has **no Wi-Fi
device** until firmware and NetworkManager Wi-Fi packages are installed into the
target root **before the first reboot**.

When Anaconda reports installation complete, **do not reboot yet** if you still
need the live-ISO firmware fix below.

## 4. Live installer: open a root shell

**Where:** live installer environment, after install finished, before reboot.

### Virtual terminals

Many laptop keyboards expose F-keys as media keys. Prefer:

```text
Ctrl + Alt + Fn + F2
```

Try `F1` through `F6` the same way until you reach Anaconda's tmux console.

In tmux, open the root shell:

```text
Ctrl+b
release
2
```

Return to the graphical installer later with:

```text
Ctrl + Alt + Fn + F6
```

Try `F1`–`F7` if F6 is empty. Installation can continue while you work on
another VT; do not reboot until the firmware step finishes.

### Optional read-only inspection

```bash
lspci -nnk | grep -A4 -Ei 'network|wireless'
dmesg | grep -i iwlwifi
uname -r
ip link
```

This laptop path expects **Intel** wireless with kernel driver **`iwlwifi`**.
Other chipsets: use the same `lspci` / `dmesg` inspection, identify the driver
and firmware package names, and substitute those packages in the install step
below instead of the `iwlwifi*` globs.

## 5. Live installer: enter the installed system

**Where:** installer root shell. Target root is usually `/mnt/sysroot`.

```bash
ls /mnt/sysroot
```

Expect `etc`, `home`, `usr`, `boot`, and similar. If that path is empty, try:

```bash
ls /mnt/sysimage
```

Use whichever contains the installed root. The commands below assume
`/mnt/sysroot`.

```bash
mount --bind /dev /mnt/sysroot/dev
mount --bind /dev/pts /mnt/sysroot/dev/pts
mount --bind /proc /mnt/sysroot/proc
mount --bind /sys /mnt/sysroot/sys
mount --bind /run /mnt/sysroot/run
cp -L /etc/resolv.conf /mnt/sysroot/etc/resolv.conf
chroot /mnt/sysroot /bin/bash
```

`ttyname: No such device` on `chroot` is often harmless. Confirm you are inside
the installed system:

```bash
ls /home
```

Your administrative user directory should appear.

### Fallback without an interactive chroot

From the installer shell (not inside chroot):

```bash
dnf --installroot=/mnt/sysroot --releasever=44 install \
  linux-firmware \
  'iwlwifi*-firmware' \
  NetworkManager-wifi \
  kernel-modules \
  kernel-modules-extra \
  pciutils \
  usbutils \
  iw \
  rfkill
```

If DNF errors on repositories with `--installroot`, stop and fix repo/DNS
access before rebooting.

## 6. Live installer: install firmware and Wi-Fi into the target

**Where:** inside the chroot (or via `--installroot` as above). Uses the live
environment's working network while writing packages into the installed root.

Intel Wi-Fi path:

```bash
dnf install linux-firmware NetworkManager-wifi
dnf install 'iwlwifi*-firmware'
dnf install kernel-modules kernel-modules-extra
dnf install pciutils usbutils iw rfkill
systemctl enable NetworkManager
```

`systemctl` may warn that it is not running inside the chroot; enabling for the
next boot is enough.

Checkpoint before leaving:

```bash
rpm -qa | grep -Ei 'iwlwifi|linux-firmware|NetworkManager-wifi'
ls /usr/lib/firmware | grep -i iwl | head
```

**Skip `dracut` unless** Wi-Fi still fails after first boot with modules or
firmware missing from the early boot path. Intel Wi-Fi is not required to mount
`/`; a normal reboot after the packages above is usually sufficient.

Do not install the full desktop or development stack here. Bootstrap and
`laptop-setup` own the rest.

Exit the chroot:

```bash
exit
```

## 7. Reboot into the installed system

**Where:** live installer UI, then installed TTY.

1. Return to the installer UI: `Ctrl + Alt + Fn + F6`.
2. Choose **Reboot**.
3. When the machine starts rebooting (screen blanks), **remove the USB stick**.
4. Boot from the internal disk and log in on the TTY as your admin user.

### Confirm Wi-Fi

```bash
nmcli device
nmcli radio wifi on
nmcli device wifi list
nmcli device wifi connect "YOUR_SSID" --ask
ping -c 3 fedoraproject.org
```

Expect a `wifi` device (for example `wlp…`) once firmware is present. If the
device is still missing, re-check `dmesg | grep -i iwlwifi` and installed
firmware packages before reinstalling the OS.

Optional TTY font (session-only until persisted):

```bash
setfont latarcyrheb-sun32
```

Persist via `FONT=` in `/etc/vconsole.conf` if desired. Graphical terminal fonts
are configured later by setup.

Optional baseline update before bootstrap:

```bash
sudo dnf upgrade --refresh
```

Reboot again if the kernel updated.

## 8. Bootstrap laptop-setup

**Where:** installed system, working network, administrative user. The
repository need not exist yet.

```bash
curl -fsSL https://raw.githubusercontent.com/bharatsuri1/dotfiles-fedora/main/bootstrap.sh | bash
```

Preview without changing the machine:

```bash
curl -fsSL https://raw.githubusercontent.com/bharatsuri1/dotfiles-fedora/main/bootstrap.sh \
  | bash -s -- --dry-run apply
```

Bootstrap clones or updates
`~/.local/share/dotfiles-fedora` (override with
`DOTFILES_FEDORA_INSTALL_ROOT`), installs the `laptop-setup` wrapper under
`~/.local/bin`, and runs guided `apply` unless you pass other arguments. Reruns
are safe: phases detect completed work. Full CLI behavior is in the
[README](../README.md).

### First checkpoints after apply

| Check | Command / action |
| --- | --- |
| Managed state | `laptop-setup status` |
| Local checkout without fetching | `cd ~/.local/share/dotfiles-fedora && ./bin/laptop-setup --dry-run apply` |
| First graphical session | From a TTY: `niri-session` |
| Optional graphical login | After TTY recovery works: `laptop-setup sddm-enable` |
| Undo graphical default boot | From a recovery TTY: `sudo systemctl set-default multi-user.target` |

Session layout, keybindings, device TUIs, and greeter rollback:

- [README — Desktop session](../README.md#desktop-session)
- [`docs/niri-input-and-keybindings.md`](niri-input-and-keybindings.md)
- [`docs/device-controls.md`](device-controls.md)
- [`docs/dms-removal-plan.md`](dms-removal-plan.md)

## Recovery quick reference

| Symptom | What to try |
| --- | --- |
| VT keys do nothing | Use `Ctrl+Alt+Fn+F1`…`F6` |
| Lost installer UI | `Ctrl+Alt+Fn+F6` (then other F-keys) |
| No `/mnt/sysroot` | Try `/mnt/sysimage`; do not guess disks |
| `chroot` tty warning | Check `ls /home`; or use `dnf --installroot` |
| Wi-Fi works in installer only | Repeat sections 4–6 before trusting first boot |
| No wifi device after reboot | `nmcli device`, `dmesg \| grep -i iwlwifi`, firmware RPMs |
| Graphical session or SDDM fails | TTY login, `niri-session`, or `sudo systemctl set-default multi-user.target` |
