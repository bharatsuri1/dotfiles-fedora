# TODO

## Priority 1: DMS removal and custom Quickshell shell

The completed migration decisions and verification record live in
[`docs/dms-removal-plan.md`](docs/dms-removal-plan.md). Continue the remaining
tickets in order so the machine retains its tested bare-niri recovery path.

### Ticket 1: Capture DMS state and migration requirements

- [x] Audit the current DMS, DMS Greeter, niri, Quickshell, systemd, configuration, data, ACL, and COPR coupling.
- [x] Document a staged, non-executing DMS removal and bare-niri recovery plan.
- [x] Export any wanted DMS notepad content, settings, theme data, and generated display configuration before cleanup.
- [x] Review generated DMS settings once and retain only portable niri and design defaults.
- [x] Record current DMS behavior as replacement requirements without tracking DMS application state.

### Ticket 2: Remove DMS ownership from the setup installer

- [x] Remove the DMS phase and DMS Greeter workflow from `laptop-setup apply`, command dispatch, status, and documentation.
- [x] Stop enabling the DMS and Dank Linux COPRs during niri installation; keep niri sourced independently.
- [x] Move the active `eDP-1` output configuration into repository-owned niri configuration.
- [x] Remove all DMS includes and IPC bindings from the managed niri configuration.
- [x] Ensure rerunning `laptop-setup apply` cannot reinstall, enable, or reattach DMS.
- [x] Add dry-run and validation coverage for the DMS-free installer path.

### Ticket 3: Add and wire bare-niri desktop components

- [x] Keep Fuzzel as the emergency launcher and bind it independently of the custom shell.
- [x] Select, install, configure, and start a standalone notification daemon.
- [x] Configure Swaylock and select the owner of idle detection and lock-before-suspend behavior.
- [x] Select, install, configure, and start a standalone graphical Polkit agent.
- [x] Decide whether the temporary baseline needs Waybar; keep it minimal and removable if used.
- [x] Preserve the existing portal, Xwayland Satellite, media-key, brightness, screenshot, and clipboard wiring.
- [x] Validate the complete bare-niri session from a TTY before removing DMS.

### Ticket 4: Remove DMS from the current machine

- [x] Export the data identified in Ticket 1 and take an exact pre-removal inventory.
- [x] Remove the `niri.service` want for `dms.service` without stopping the only working session prematurely.
- [x] Use the DMS Greeter uninstall path while its CLI is still present and restore a tested TTY login path.
- [x] Reboot and prove TTY login followed by `niri-session` before package removal.
- [x] Remove DMS, DMS CLI, DMS Greeter, and any now-unwanted Quickshell or greetd packages after reviewing the DNF transaction.
- [x] Disable the DMS and Dank Linux COPRs once no retained package depends on them.
- [x] Remove DMS-generated niri fragments, user configuration, state, caches, and greeter cache.
- [x] Reverse only the group membership, ACL, and ownership changes introduced by DMS Greeter sync.
- [x] Verify after reboot that no DMS process, package, repository, configuration reference, or greeter artifact remains.

### Ticket 5: Choose a DMS-independent graphical login path

- [x] Reconsider the graphical login manager only after the DMS-free TTY and niri path is proven; select SDDM for its QML theming and user-picture support.
- [x] If selected, install a non-DMS login manager and configure it to launch `niri-session`.
- [x] If selected, apply a minimal Vesper-themed greeter with matching fonts, colors, user picture, and branding.
- [ ] Enable `graphical.target` only after the replacement login manager passes recovery validation.
- [ ] Disable or remove conflicting display managers before enabling any replacement service.
- [ ] Validate login, logout, failed-login recovery, reboot, and fallback-to-TTY behavior.

### Ticket 6: Establish the custom Quickshell foundation

- [ ] Define one repository-owned Quickshell process as the optional owner of the top bar and launcher.
- [ ] Add the Quickshell package, configuration tree, systemd user service, startup ownership, logs, and restart behavior.
- [ ] Inventory Quickshell APIs and independent providers needed for niri, notifications, media, audio, network, Bluetooth, battery, and power.
- [ ] Use niri IPC and event-driven providers where possible; define polling and performance budgets.
- [ ] Implement a polished keyboard-first launcher with applications and custom actions.
- [ ] Retain a deterministic Fuzzel fallback when Quickshell or its launcher fails.
- [ ] Investigate a Quickshell-to-Elephant provider prototype without committing the architecture to it.
- [ ] Add niri, Quickshell, DMS-absence, and Xwayland checks to `laptop-setup doctor`.
- [ ] Validate one Quickshell process, no DMS process, and no overlapping shell services.

### Ticket 7: Build the macOS-style alcove and Dynamic Island

- [ ] Define a centered top-bar alcove with clear left, center, and right content ownership.
- [ ] Create a compact idle island showing workspace, focused application, and essential system status.
- [ ] Create expanded island states for notifications, media, audio, network, Bluetooth, battery, and power.
- [ ] Define priority, interruption, queueing, and timeout rules when island states compete for attention.
- [ ] Apply the Vesper palette, rounded geometry, spacing, typography, borders, blur, and shadows consistently.
- [ ] Add smooth geometry and state animations with reduced-motion support.
- [ ] Add click, scroll, hover, and keyboard interactions without conflicting with niri gestures.
- [ ] Add media controls and track metadata with graceful handling when no player is active.
- [ ] Add volume, microphone, brightness, connectivity, battery, and charging indicators.
- [ ] Add notification previews with privacy-aware redaction and do-not-disturb behavior.
- [ ] Add workspace and focused-window context without duplicating niri's overview.
- [ ] Make the alcove and island responsive across laptop, external, narrow, scaled, and multi-monitor displays.
- [ ] Define per-monitor behavior and whether expanded state follows focus or pointer location.
- [ ] Prevent the island from covering fullscreen content, overlays, screen sharing, or critical dialogs.
- [ ] Provide a minimal fallback bar when optional services or providers are unavailable.
- [ ] Validate accessibility, contrast, keyboard navigation, long text, Unicode, and localization behavior.
- [ ] Validate idle, notification, media, connectivity, power, fullscreen, lock, and multi-monitor transitions.
- [ ] Document the shell architecture, managed settings, dependencies, customization, and rollback path.

### Completed DMS checkpoint work

- [x] Select greetd with DMS Dank Greeter as the initial graphical login manager.
- [x] Add separate install and enable setup phases for DMS Greeter.
- [x] Preserve a TTY recovery path and document how to bypass or stop the graphical login manager.

## Priority 2: Desktop follow-up

- [ ] Fix niri not focusing the browser when opening a URL from Alacritty.
- [ ] Tune niri touchpad scroll direction and speed.
- [ ] Tune niri touchpad acceleration and click behavior.
- [ ] Review niri touchpad gestures without adding a conflicting gesture daemon.
- [ ] Configure niri keyboard repeat delay and rate.
- [ ] Make new niri windows open full-width by default.
- [x] Add Nerd Font icons to the Starship prompt.
- [ ] Add a niri keybinding for the default Herdr session.
- [ ] Review Fedora's current Plymouth setup, theme ownership, and initramfs integration.
- [ ] Select or create a minimal Vesper-themed Plymouth boot splash.
- [ ] Track the Plymouth theme and installation logic without modifying generated runtime state.
- [ ] Configure quiet boot while preserving access to detailed boot diagnostics.
- [ ] Rebuild the initramfs safely after installing or changing the Plymouth theme.
- [ ] Validate the splash during startup, shutdown, reboot, and boot failure recovery.
- [ ] Validate the splash with disk-unlock prompts if full-disk encryption is enabled.
- [ ] Document how to disable the custom splash and restore Fedora's default Plymouth theme.

## Priority 3: Development tools

- [ ] Add Microsoft’s official VS Code RPM repository.
- [ ] Install VS Code through DNF.
- [ ] Track minimal VS Code settings and keybindings.
- [ ] Define a small reviewed VS Code extension list.
- [x] Create a managed `config/tmux/tmux.conf` with a `Ctrl-Space` prefix.
- [x] Enable tmux mouse support, true color, extended keys, and increased scrollback history.
- [x] Start tmux window and pane numbering at 1 and renumber windows after removal.
- [x] Open new tmux windows and panes in the current working directory.
- [x] Set tmux escape time to 10 milliseconds for responsive Vim input.
- [x] Use tmux defaults to create, rename, and switch sessions and windows.
- [x] Use tmux defaults to split panes.
- [x] Add repeatable tmux `h`, `j`, `k`, and `l` keybindings to navigate panes.
- [x] Add repeatable tmux `H`, `J`, `K`, and `L` keybindings to resize panes.
- [x] Bind tmux `x` to kill the active pane without confirmation.
- [x] Add a tmux keybinding to reload the managed configuration.
- [x] Enable vi-style tmux copy mode.
- [x] Copy tmux copy-mode selections with `wl-copy` on Wayland.
- [x] Link the managed tmux configuration during the `config` setup phase.
- [x] Reload the managed tmux configuration during setup when a tmux server is running.
- [x] Install Sesh and bind its built-in session picker to tmux `K`.
- [x] Add managed Sesh defaults, shell aliases, and last-session navigation.
- [x] Report the managed tmux configuration link in `status`.
- [x] Add a modular Vesper-themed tmux status bar and tune it interactively.
- [x] Document tmux in the README managed scope.
- [x] Validate the managed tmux configuration and setup scripts.
- [ ] Review `agavra/tuicr` installation, dependencies, and package ownership.
- [ ] Install and configure `tuicr` through the selected package source.

## Priority 4: Security and laptop policy

- [ ] Install and enable Fedora’s firewall service.
- [ ] Define a minimal inbound firewall policy.
- [ ] Document how Docker-published ports interact with the firewall.
- [ ] Choose the owner of idle detection and screen locking.
- [ ] Configure idle screen locking.
- [ ] Configure display power-off timeout.
- [ ] Configure suspend timeout and lid-close behavior.
- [ ] Configure lock-before-suspend behavior.
- [ ] Review AC versus battery power behavior.

## Priority 5: Optional applications

- [x] Add setup support for a minimal managed Chromium policy that disables password saving, site notifications, and default-browser prompts.
- [ ] Audit desired communication applications and choose package sources.
- [ ] Audit desired media applications and choose package sources.
- [ ] Audit desired productivity applications and choose package sources.
- [ ] Add each approved optional application in a separate commit.
- [ ] Add Restic after defining repository and credential inputs.

- [ ] Document the initial Fedora custom online installation, including switching to a terminal with `Ctrl+Alt+Fn+F1` and manually installing the Wi-Fi firmware required after boot.
- [ ] Manage Codex configuration through setup, following the existing Pi `config/pi/settings.json` pattern.
  - [ ] Inventory `~/.codex` and identify portable settings for a repository-owned `config/codex/config.toml`.
  - [ ] Exclude credentials, sessions, logs, caches, and other machine-specific runtime state.
  - [ ] Link the managed configuration from the `config` setup phase without silently overwriting local configuration.
  - [ ] Report the Codex configuration link in `status`.
  - [ ] Validate CLI loading, shell syntax, and a focused `--dry-run config` run.

## Priority 6: Setup observability

- [x] Report Nerd Font availability in `status`.
- [x] Report the default browser in `status`.
- [x] Report the login shell in `status`.
- [x] Report the graphical login manager in `status`.
- [ ] Report all managed configuration links in `status`.
- [ ] Add a `doctor` command dispatcher.
- [ ] Add graphics and VA-API checks to `doctor`.
- [ ] Add audio and media-control checks to `doctor`.
- [ ] Add Bluetooth service and adapter checks to `doctor`.
- [ ] Add keyring, Secret Service, and Polkit checks to `doctor`.
- [ ] Add portal backend checks to `doctor`.
- [ ] Add keyd configuration and service checks to `doctor`.
- [ ] Add Docker, Mise, Node, Pi, Codex, and Herdr checks to `doctor`.

## Priority 7: Manual validation

- [ ] Validate graphics acceleration and VA-API decoding.
- [ ] Validate speakers, microphone, headphones, and media keys.
- [ ] Validate Bluetooth discovery, pairing, reconnect, and audio profiles.
- [ ] Validate keyring unlock and Secret Service persistence after login.
- [ ] Validate a graphical Polkit authentication prompt.
- [ ] Validate screen sharing and file dialogs through portals.
- [ ] Validate brightness control and Wayland clipboard behavior.
- [ ] Validate browser, file, media, image, and PDF MIME handlers.
- [ ] Validate Noto UI, emoji, and CJK font fallback.
- [ ] Validate a native Wayland application.
- [ ] Validate an X11 application through Xwayland Satellite.
- [ ] Validate niri logout and recovery to a TTY.
- [ ] Validate keyd tap/hold behavior and TTY recovery.

## Priority 8: Automation and maintenance

- [ ] Add Bash syntax checks to CI.
- [ ] Add Zsh syntax checks to CI.
- [ ] Add ShellCheck to CI.
- [ ] Add whitespace and JSON/TOML validation to CI.
- [ ] Add niri configuration validation to CI where available.
- [ ] Document update commands for DNF, Flatpak, Homebrew, Mise, and Herdr.
- [ ] Document removal and rollback steps for external repositories.
- [ ] Document post-install next steps and print them when setup finishes, including `gh auth login` and `gh auth setup-git`.
