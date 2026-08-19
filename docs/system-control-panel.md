# System control panel (Tmux session)

A terminal-based system control panel launched via a niri keybind and managed
through [Sesh](https://github.com/joshmedeski/sesh).  It opens a Tmux session
with a single window containing four split panes, each running a TUI for a
different subsystem.

## Overview

| Component | Role |
| --- | --- |
| **Niri keybind** | `Super+Ctrl+P` launches Alacritty and attaches to the Sesh session |
| **Sesh session** | `control-panel` session defined in `config/sesh/sesh.toml` |
| **Startup script** | `config/sesh/scripts/control-panel.sh` builds the 4-pane grid |
| **Window rule** | Niri opens the terminal as a 1200×800 floating window |

## Pane layout

```
┌──────────────────┬──────────────────┐
│  0  Wi-Fi        │  1  Bluetooth    │
│     wlctl         │     bluetui      │
├──────────────────┼──────────────────┤
│  2  Audio        │  3  System monitor│
│     wiremix       │     btop         │
└──────────────────┴──────────────────┘
```

| Pane | Tool | Backing service | Purpose |
| --- | --- | --- | --- |
| 0 | `wlctl` | `NetworkManager.service` | Scan, connect, disconnect, and troubleshoot Wi-Fi |
| 1 | `bluetui` | `bluetooth.service` | Scan, pair, trust, connect, and unpair Bluetooth devices |
| 2 | `wiremix` | PipeWire + WirePlumber | Volume, mute, default-device, and stream routing |
| 3 | `btop` | — | CPU, memory, network, and process monitoring |

Focus starts on pane 0 (Wi-Fi).  All four tools are already installed by the
`device-controls` phase; see
[device-controls.md](device-controls.md) for their ownership, backing
services, and recovery procedures.

## How it works

1. **Keybind**: `Super+Ctrl+P` in Niri spawns
   `alacritty --class ControlPanel --title "Control Panel" -e sesh connect control-panel`.
2. **Sesh** looks up the `control-panel` session in `sesh.toml`.  If the
   session already exists, Sesh attaches to it.  If it does not, Sesh creates
   a new Tmux session at `~` with one window named `control-panel`.
3. **Startup script**: Sesh runs
   `~/.config/sesh/scripts/control-panel.sh` in the first pane of the new
   window.  The script uses `tmux split-window` to create three additional
   panes, arranges them with `select-layout tiled`, and sends a TUI command
   to each pane.
4. **Window rule**: Niri matches the `ControlPanel` app-id and opens the
   terminal as a 1200×800 floating window, so the control panel sits on top
   of the tiling layout like a dashboard.

Using an external shell script (rather than inline `startup_command` tmux
commands) avoids the keystroke race conditions documented in
[sesh#314](https://github.com/joshmedeski/sesh/issues/314).  Sesh sends a
single line (`bash ~/.config/sesh/scripts/control-panel.sh`) to the pane, so
all tmux commands execute sequentially and atomically.

## Configuration files

### `config/sesh/sesh.toml`

```toml
[[session]]
name = "control-panel"
path = "~"
windows = ["control-panel"]

[[window]]
name = "control-panel"
startup_script = "~/.config/sesh/scripts/control-panel.sh"
```

### `config/sesh/scripts/control-panel.sh`

An executable script that splits the window into four panes and launches
`wlctl`, `bluetui`, `wiremix`, and `btop` in each.

### `config/niri/config.kdl`

```kdl
Mod+Ctrl+P repeat=false hotkey-overlay-title="Open Control Panel" {
    spawn "alacritty" "--class" "ControlPanel" "--title" "Control Panel" "-e" "sesh" "connect" "control-panel";
}
```

A window rule matches `app-id="^ControlPanel$"` and opens it floating at
1200×800.

## Idempotence and reconnection

Sesh's `connect` command is idempotent: if the `control-panel` session already
exists, Sesh attaches to it without re-running the startup script.  This means
pressing `Super+Ctrl+P` a second time opens a second terminal attached to the
same session (a second client), rather than creating duplicate panes.  Closing
either client leaves the session and its panes intact.

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

1. Press `Super+Ctrl+P` and confirm a floating Alacritty window opens with
   four panes, each showing a TUI.
2. Interact with each pane:
   - Wi-Fi: scan and connect to a network with `wlctl`.
   - Bluetooth: scan and pair a device with `bluetui`.
   - Audio: adjust volume with `wiremix`.
   - System monitor: confirm `btop` shows CPU, memory, and processes.
3. Close the terminal and press `Super+Ctrl+P` again.  The session should
   reattach with the same panes still running.
4. Kill the session with `tmux kill-session -t control-panel`, then press
   `Super+Ctrl+P` again.  The session should recreate with fresh panes.

Validate the niri configuration:

```bash
niri validate -c config/niri/config.kdl
```

Validate the startup script syntax:

```bash
bash -n config/sesh/scripts/control-panel.sh
shellcheck config/sesh/scripts/control-panel.sh
```