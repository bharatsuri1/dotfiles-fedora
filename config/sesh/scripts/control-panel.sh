#!/usr/bin/env bash
set -Eeuo pipefail

# Build a 2×2 grid of system-control TUIs in the current tmux window.
# Invoked by sesh as the window's startup_script when connecting to the
# "control-panel" session.  The script runs inside pane 0 of the new window,
# so every tmux command targets the session that just spawned it.

# ── Pane layout ──────────────────────────────────────────────────────
#   ┌──────────────────┬──────────────────┐
#   │  0  Wi-Fi (wlctl) │  1  Bluetooth    │
#   │                   │     (bluetui)     │
#   ├──────────────────┼──────────────────┤
#   │  2  Audio         │  3  System monitor│
#   │     (wiremix)     │     (btop)        │
#   └──────────────────┴──────────────────┘

# Pane 0 already exists.  Create three splits to reach four panes.
tmux split-window -h -c "#{pane_current_path}"       # pane 1 — right column
tmux split-window -v -t 0 -c "#{pane_current_path}"  # pane 2 — left-bottom
tmux split-window -v -t 1 -c "#{pane_current_path}"  # pane 3 — right-bottom

# Even out pane sizes into a clean 2×2 grid.
tmux select-layout tiled

# Launch a TUI in each pane.
tmux send-keys -t 0 "wlctl" Enter      # Wi-Fi
tmux send-keys -t 1 "bluetui" Enter    # Bluetooth
tmux send-keys -t 2 "wiremix" Enter    # Audio
tmux send-keys -t 3 "btop" Enter       # System monitor

# Put focus on the Wi-Fi pane (top-left).
tmux select-pane -t 0