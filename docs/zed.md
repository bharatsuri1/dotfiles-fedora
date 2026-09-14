# Zed

Zed is installed from the official stable Linux archive, rather than Flatpak.
The `zed` phase verifies the pinned bootstrap archive before atomically placing
it at `~/.local/zed.app`; its executable is linked at `~/.local/bin/zed`,
which is already on the managed path. The desktop entry uses absolute paths
into that directory. The initial verified release is 1.19.2.

Zed may update itself normally. A managed-install marker lives under
`~/.local/state/dotfiles-fedora/zed/`, so future setup runs preserve a valid,
newer upstream-updated installation rather than downgrading it. The
`system-tools` phase installs `rsync`, which Zed requires for auto-updates.

| Configuration | Repository source | Native destination |
| --- | --- | --- |
| Settings | `config/zed/settings.json` | `~/.config/zed/settings.json` |
| Keymap | `config/zed/keymap.json` | `~/.config/zed/keymap.json` |
| Vesper theme | `config/zed/themes/vesper.json` | `~/.config/zed/themes/vesper.json` |

`Super+Ctrl+Z` launches `zed` from Niri. Native data, logs,
extensions, and cache remain user-owned, normally under `~/.local/share/zed`
and the XDG cache directory. The migration deliberately does not copy or delete
the old Flatpak state.

## Commands

```bash
./bin/fedora-setup zed
./bin/fedora-setup status
```

Use native Wayland by default. If Wayland is still unusable after diagnosis, a
one-off XWayland fallback is `WAYLAND_DISPLAY="" ~/.local/bin/zed`.

To remove only old Flatpak state after confirming the native app works, move
`~/.var/app/dev.zed.Zed` to the desktop trash. Do not remove the native paths
above.
