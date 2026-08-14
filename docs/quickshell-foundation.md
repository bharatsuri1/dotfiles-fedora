# Quickshell foundation

Status: foundation complete (Ticket 6). The repository owns one Quickshell
process per session. A static clock-and-battery center alcove is implemented
on top of it; see [`quickshell-island.md`](quickshell-island.md). Motion,
richer island states, and the launcher remain follow-up work.

## Package source

Fedora ships Quickshell in the official `updates` repository, so no COPR is
required:

```
$ dnf info quickshell
quickshell-0.2.1^git20260209.dacfa9d-3.fc44.x86_64
```

The package provides both `/usr/bin/quickshell` and `/usr/bin/qs`. It depends on
`qt6-qtsvg` (so SVG icons load), `qt6-qtwayland`, and the Qt 6 private APIs it
relies on. Because Quickshell depends on Qt private APIs it will be rebuilt with
every Qt release; the Fedora package is rebuilt accordingly, so we track the
distro package rather than pinning a git snapshot.

Upstream released 0.3.0 (2026-05-04); the Fedora 44 build tracks a 0.2.1 git
snapshot. The 0.3 QML API this configuration targets (ShellRoot, PanelWindow,
Variants, SystemClock) is stable across both lines, so distro upgrades should
not require a shell edit.

## Run model

`quickshell` loads `~/.config/quickshell/shell.qml` by default. Other selection
options (from `src/launch/parsecommand.cpp`):

- `-p, --path <dir|file>` run an explicit config directory or shell file.
- `-c, --config <name>` run `<xdg dir>/quickshell/<name>/shell.qml`.
- `-m, --manifest` is deprecated; we do not ship a manifest.
- `-d, --daemonize` and `--no-duplicate` exist, but we run a plain foreground
  process so systemd manages the lifecycle.

Quickshell hot-reloads the shell when the entry file changes. The Fedora
0.2.1 build watches only `shell.qml`, not the whole tree, so after editing
any other file force a clean reload with `systemctl --user restart
quickshell.service`. The managed symlink points at the repo, so a `git pull`
plus a restart applies updates live.

## Repository-owned configuration

- `config/quickshell/` — the shell tree (`shell.qml` entry point, `theme/`
  design tokens, `island/` components), linked as a whole to
  `~/.config/quickshell` by the `config` phase.
- `config/systemd/user/quickshell.service` — the systemd user unit, linked to
  `~/.config/systemd/user/quickshell.service` and attached to the niri session.

The `install_quickshell` phase only installs the `quickshell` package. The
`config` phase links the shell and unit, reloads the user manager, attaches the
unit to `niri.service` (via `niri.service.wants/`), and restarts it when a
graphical session is active.

## systemd lifecycle and safeguards

```
[Unit]
Description=Managed Quickshell shell for the niri session
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target
StartLimitIntervalSec=30
StartLimitBurst=5

[Service]
Type=simple
ExecStart=/usr/bin/quickshell
Restart=on-failure
RestartSec=5
TimeoutStopSec=5
StandardOutput=journal
StandardError=journal
```

Safeguards:

- `Requisite=graphical-session.target` prevents the unit from starting outside a
  Wayland session and prevents restart loops on a headless boot.
- `PartOf=graphical-session.target` stops Quickshell with the session.
- Attachment through `niri.service.wants/` makes Quickshell start when niri
  starts, alongside mako, swaybg, swayidle, and the polkit agent.
- `Restart=on-failure` with `RestartSec=5` and a 30s/5 burst start limit recovers
  from a Quickshell crash without hammering the compositor.
- `StandardOutput/Error=journal` capture logs to journald.

## Logging and inspection

Logs are read through journald:

```
journalctl --user -u quickshell.service -f
systemctl --user status quickshell.service
quickshell log -f        # upstream log reader, if preferred
```

`laptop-setup status` reports the Quickshell package, the managed shell symlink,
the service attachment, and the active/inactive state.

## Fallback

- Fuzzel remains the launcher fallback. niri binds `Mod+Space` to `fuzzel`
  independently of Quickshell, so a Quickshell crash never removes app
  launching. The launcher built on Quickshell later (Ticket 6 follow-up) will
  bind to a separate key and coexist with Fuzzel.
- A top bar is cosmetic. If Quickshell fails, the rest of the bare-niri session
  (niri, mako, swayidle, gtklock, polkit, portals) keeps working unchanged.
- To force a clean reload: `systemctl --user restart quickshell.service`.
- To roll back: `systemctl --user disable --now quickshell.service`,
  `laptop-setup` re-link is idempotent; remove the symlink to revert to no bar.

## Provider inventory

Niri has no native Quickshell module (only `Quickshell.Hyprland`,
`Quickshell.I3`, and generic `Quickshell.Wayland` exist). The static MVP uses
UPower; the rest remains follow-up:

| Concern | Plan | Provider |
| --- | --- | --- |
| Workspaces / focus / windows | niri IPC event stream (`niri msg event-stream`) or `niri msg --json` queries | `Quickshell.Io` (Process / Socket / StdioCollector) |
| Notifications | already handled by mako | none needed in shell; shell mirrors via notification server later |
| Media | MPRIS | `Quickshell.Services.Mpris` |
| Audio | PipeWire | `Quickshell.Services.Pipewire` |
| Network | NetworkManager | `Quickshell.Networking` |
| Bluetooth | BlueZ | `Quickshell.Bluetooth` |
| Battery / power | UPower | `Quickshell.Services.UPower` (in use) |
| System tray | StatusNotifier | `Quickshell.Services.SystemTray` |
| Lock screen | gtklock already owns it | none needed in shell |

## Performance budget

Goal: event-driven providers, zero steady-state polling. The shell satisfies
this: `SystemClock` at minute precision is the only timer, while UPower updates
through signals. Future providers should subscribe to niri IPC and DBus
signals. Any unavoidable poll must stay at or below a 1 Hz cadence and be
documented here.

## Validation

From a TTY-started niri session, after `laptop-setup apply`:

1. `systemctl --user status quickshell.service` shows active.
2. The alcove renders centered and flush with the top edge of `eDP-1`.
3. `laptop-setup status` reports `[ok] quickshell`, `[managed]` for the exact
   Quickshell directory link, and `[active] quickshell.service`.
4. `pgrep -x quickshell` returns exactly one process.
5. `journalctl --user -u quickshell.service` shows no Qt/Wayland errors.
6. Fuzzel still launches on `Mod+Space` and survives a Quickshell restart.
7. `systemctl --user stop quickshell.service` stops the bar without disturbing
   the session, and `Restart` restores it after recompose.
