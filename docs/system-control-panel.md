# System control panel (Tmux session)

A terminal-based system control panel launched via a niri keybind and managed
through [Sesh](https://github.com/joshmedeski/sesh).  It opens a Tmux session
with six windows, each running a full-screen TUI for a different subsystem.

## Overview

| Component | Role |
| --- | --- |
| **Niri keybind** | `Super+Shift+C` launches Alacritty with the full sesh path |
| **Sesh session** | `control-panel` session defined in `config/sesh/sesh.toml` |
| **Startup script** | `config/sesh/scripts/control-panel.sh` creates the 6 windows |
| **Window rule** | Niri opens the terminal as a 1400×900 floating window |

## Windows

| # | Name | Tool | Backing service | Purpose |
| --- | --- | --- | --- | --- |
| 1 | Wi-Fi | `wlctl` | `NetworkManager.service` | Scan, connect, disconnect, and troubleshoot Wi-Fi |
| 2 | Bluetooth | `bluetui` | `bluetooth.service` | Scan, pair, trust, connect, and unpair Bluetooth devices |
| 3 | Audio | `wiremix` | PipeWire + WirePlumber | Volume, mute, default-device, and stream routing |
| 4 | Services | `systemctl-tui` | systemd | Browse, start, stop, restart services; view logs |
| 5 | Disk | `diskonaut` | — | Visual treemap disk usage analyzer |
| 6 | Monitor | `btop` | — | CPU, memory, battery, network, and process monitoring |

Focus starts on window 1 (Wi-Fi).  Switch between windows with the tmux prefix
(`C-Space` followed by the window number).

### Installation phases

| Tool | Phase | Source |
| --- | --- | --- |
| `wlctl`, `bluetui`, `wiremix` | `device-controls` | Pinned binaries / DNF |
| `systemctl-tui` | `system-tools` | Pinned binary (v0.8.0) |
| `diskonaut`, `powertop` | `system-tools` | Fedora DNF |
| `btop` | `packages` | Fedora DNF |

See [device-controls.md](device-controls.md) for wlctl, Bluetui, and wiremix
ownership and recovery.  See the `system-tools` phase for systemctl-tui,
bandwhich, batctl, diskonaut, and powertop.

## How it works

1. **Keybind**: `Super+Shift+C` in Niri spawns Alacritty with
   `--class ControlPanel` and runs `sesh connect control-panel` using the
   full path to the sesh binary (`/home/linuxbrew/.linuxbrew/bin/sesh`),
   since Niri's spawn PATH does not include the Linuxbrew directory.
2. **Sesh** looks up the `control-panel` session in `sesh.toml`.  If the
   session already exists, Sesh attaches to it.  If it does not, Sesh creates
   a new Tmux session at `~` with a single default window.
3. **Startup script**: Sesh runs
   `~/.config/sesh/scripts/control-panel.sh` as the session's
   `startup_command`.  The script renames the default window to "Wi-Fi" and
   launches `wlctl`, then creates five additional windows via
   `tmux new-window` — each with its own TUI — and returns focus to window 1.
4. **Window rule**: Niri matches the `ControlPanel` app-id and opens the
   terminal as a 1400×900 floating window, so the control panel sits on top
   of the tiling layout like a dashboard.

Using an external shell script (rather than sesh's `windows`/`[[window]]`
config) avoids the extra default-window issue documented in
[sesh#314](https://github.com/joshmedeski/sesh/issues/314).  Sesh sends a
single line to the pane, so all tmux commands execute sequentially and
atomically.

## Configuration files

### `config/sesh/sesh.toml`

```toml
[[session]]
name = "control-panel"
path = "~"
startup_command = "~/.config/sesh/scripts/control-panel.sh"
```

### `config/sesh/scripts/control-panel.sh`

An executable script that renames the default window and creates five
additional windows, launching a TUI in each:

```
1  Wi-Fi          wlctl
2  Bluetooth      bluetui
3  Audio          wiremix
4  Services       systemctl-tui
5  Disk           diskonaut /
6  Monitor        btop
```

### `config/niri/config.kdl`

```kdl
Mod+Shift+C repeat=false hotkey-overlay-title="Open Control Panel" {
    spawn "alacritty" "--class" "ControlPanel" "--title" "Control Panel" "-e" "/home/linuxbrew/.linuxbrew/bin/sesh" "connect" "control-panel";
}
```

The full path to sesh is used because Niri's spawn PATH does not include
Linuxbrew.

A window rule matches `app-id="^ControlPanel$"` and opens it floating at
1400×900.

## Idempotence and reconnection

Sesh's `connect` command is idempotent: if the `control-panel` session already
exists, Sesh attaches to it without re-running the startup script.  This means
pressing `Super+Shift+C` a second time opens a second terminal attached to the
same session (a second client), rather than creating duplicate windows.
Closing either client leaves the session and its windows intact.

To kill the session entirely and start fresh, use the tmux prefix:

```
C-Space : kill-session
```

Or from a shell:

```bash
tmux kill-session -t control-panel
```

## Validation

After applying the configuration:

1. Press `Super+Shift+C` and confirm a floating Alacritty window opens.
2. Verify six tmux windows, each showing a TUI:
   - Wi-Fi: scan and connect to a network with `wlctl`.
   - Bluetooth: scan and pair a device with `bluetui`.
   - Audio: adjust volume with `wiremix`.
   - Services: `systemctl-tui` shows unit list and journal logs.
   - Disk: `diskonaut` shows treemap of `/`.
   - Monitor: `btop` shows CPU, memory, and processes.
3. Close the terminal and press `Super+Shift+C` again.  The session should
   reattach with the same windows still running.
4. Kill the session with `tmux kill-session -t control-panel`, then press
   `Super+Shift+C` again.  The session should recreate with fresh windows.

Validate the niri configuration:

```bash
niri validate -c config/niri/config.kdl
```

Validate the startup script syntax:

```bash
bash -n config/sesh/scripts/control-panel.sh
shellcheck config/sesh/scripts/control-panel.sh
```