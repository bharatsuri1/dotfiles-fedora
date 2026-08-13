# TODO

## Priority 1: Immediate setup

1. Configure minimal DMS defaults and application preferences.
2. Tune niri touchpad scrolling, acceleration, gestures, and click behavior.
3. Configure keyboard repeat delay and rate for the niri session.
4. Make new niri windows open full-width by default.
5. Enhance Starship with Nerd Font icons.
6. Add a niri keybinding to launch the default Herdr session.
7. Install Pi globally through Mise-managed npm.
8. Install Codex globally through Mise-managed npm.
9. Add a modern graphical login manager that starts niri directly.
10. Add Microsoft VS Code from its official Fedora repository.
11. Add tmux configuration.
12. Add firewall defaults.
13. Add power, idle, lock, and suspend policy.
14. Select and add optional desktop applications.
15. Complete deferred validation, `status`, `doctor`, and CI work.

## Priority 2: Validation and health tooling

- Validate graphics acceleration and VA-API.
- Validate PipeWire, WirePlumber, audio devices, and media controls.
- Validate Bluetooth discovery, pairing, reconnect, and audio profiles.
- Validate GNOME Keyring, Secret Service, and Polkit integration.
- Validate portals, screen sharing, file dialogs, and Flatpak integration.
- Validate brightness control and Wayland clipboard behavior.
- Validate desktop applications, MIME handlers, and fallback fonts.
- Validate native Wayland applications and Xwayland Satellite fallback.
- Validate niri and DMS lifecycle with no overlapping shell services.
- Validate keyd mapping and preserve a TTY recovery path.
- Expand `status` coverage for fonts, browser, login shell, and all managed links.
- Add a `doctor` command for runtime health checks.
- Add Bash/Zsh syntax, ShellCheck, and whitespace CI.
