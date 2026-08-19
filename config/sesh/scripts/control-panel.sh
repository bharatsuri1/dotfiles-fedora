#!/usr/bin/env bash
set -Eeuo pipefail

# Build a system control panel with six tmux windows, each running a TUI
# for a different subsystem.  Invoked by sesh as the session's
# startup_command when connecting to "control-panel".  The script runs
# inside the first (default) window, so tmux commands target the current
# session.
#
# ── Windows ──────────────────────────────────────────────────────────
#   1  Wi-Fi          wlctl
#   2  Bluetooth      bluetui
#   3  Audio          wiremix
#   4  Services       systemctl-tui
#   5  Disk           diskonaut
#   6  Monitor        btop

# Window 1 already exists — rename it and launch the first TUI.
tmux rename-window "Wi-Fi"
tmux send-keys "wlctl" Enter

# Create the remaining windows, each with its own TUI.
tmux new-window -n "Bluetooth"
tmux send-keys "bluetui" Enter

tmux new-window -n "Audio"
tmux send-keys "wiremix" Enter

tmux new-window -n "Services"
tmux send-keys "systemctl-tui" Enter

tmux new-window -n "Disk"
tmux send-keys "diskonaut /" Enter

tmux new-window -n "Monitor"
tmux send-keys "btop" Enter

# Return to the first window (Wi-Fi).
tmux select-window -t 1