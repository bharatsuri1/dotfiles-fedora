# TODO

## Priority 1: Desktop experience

- [ ] Review generated DMS settings and identify portable defaults.
- [ ] Track minimal DMS application preferences.
- [ ] Review DMS top-bar extension points and confirm DMS owns the desktop bar.
- [ ] Inventory available DMS widgets, state providers, animations, and popup APIs.
- [ ] Define a centered floating-island layout with clear left, center, and right content ownership.
- [ ] Create a compact idle state that shows workspace, focused application, and essential system status.
- [ ] Create expanded island states for notifications, media, audio, network, Bluetooth, battery, and power.
- [ ] Define priority and timeout rules when multiple island states compete for attention.
- [ ] Apply the Vesper palette, rounded geometry, spacing, typography, borders, and shadows consistently.
- [ ] Add smooth state transitions and size animations with reduced-motion support.
- [ ] Add click, scroll, hover, and keyboard interactions without conflicting with niri gestures.
- [ ] Add media controls and track metadata with graceful handling when no player is active.
- [ ] Add volume, microphone, brightness, network, Bluetooth, battery, and charging indicators.
- [ ] Add notification previews with privacy-aware redaction and do-not-disturb behavior.
- [ ] Add workspace and focused-window context without duplicating niri's overview.
- [ ] Make the island responsive across laptop, external, narrow, scaled, and multi-monitor displays.
- [ ] Define per-monitor behavior and choose whether expanded state follows focus or pointer location.
- [ ] Prevent the island from covering fullscreen content, overlays, screen sharing, or critical dialogs.
- [ ] Keep state-provider polling event-driven where possible and define a performance budget.
- [ ] Provide a minimal fallback bar when optional services or state providers are unavailable.
- [ ] Validate accessibility, contrast, keyboard navigation, long text, Unicode, and localization behavior.
- [ ] Validate idle, notification, media, connectivity, power, fullscreen, lock, and multi-monitor transitions.
- [ ] Document the island architecture, managed settings, dependencies, customization, and rollback path.
- [ ] Tune niri touchpad scroll direction and speed.
- [ ] Tune niri touchpad acceleration and click behavior.
- [ ] Review niri touchpad gestures without adding a conflicting gesture daemon.
- [ ] Configure niri keyboard repeat delay and rate.
- [ ] Make new niri windows open full-width by default.
- [x] Add Nerd Font icons to the Starship prompt.
- [ ] Add a niri keybinding for the default Herdr session.
- [ ] Select a graphical login manager compatible with niri.
- [ ] Install the selected graphical login manager from a reviewed Fedora package source.
- [ ] Configure the login manager to offer and launch the managed niri session.
- [ ] Apply a minimal Vesper-themed graphical greeter with matching fonts, colors, and branding.
- [ ] Enable `graphical.target` and start the graphical login manager automatically at boot.
- [ ] Disable or remove conflicting display managers before enabling the selected service.
- [ ] Preserve a TTY recovery path and document how to bypass or stop the graphical login manager.
- [ ] Validate login, logout, failed-login recovery, reboot, and fallback-to-TTY behavior.
- [ ] Review Fedora's current Plymouth setup, theme ownership, and initramfs integration.
- [ ] Select or create a minimal Vesper-themed Plymouth boot splash.
- [ ] Track the Plymouth theme and installation logic without modifying generated runtime state.
- [ ] Configure quiet boot while preserving access to detailed boot diagnostics.
- [ ] Rebuild the initramfs safely after installing or changing the Plymouth theme.
- [ ] Validate the splash during startup, shutdown, reboot, and boot failure recovery.
- [ ] Validate the splash with disk-unlock prompts if full-disk encryption is enabled.
- [ ] Document how to disable the custom splash and restore Fedora's default Plymouth theme.

## Priority 2: Development tools

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

## Priority 3: Security and laptop policy

- [ ] Install and enable Fedora’s firewall service.
- [ ] Define a minimal inbound firewall policy.
- [ ] Document how Docker-published ports interact with the firewall.
- [ ] Choose the owner of idle detection and screen locking.
- [ ] Configure idle screen locking.
- [ ] Configure display power-off timeout.
- [ ] Configure suspend timeout and lid-close behavior.
- [ ] Configure lock-before-suspend behavior.
- [ ] Review AC versus battery power behavior.

## Priority 4: Optional applications

- [ ] Audit desired communication applications and choose package sources.
- [ ] Audit desired media applications and choose package sources.
- [ ] Audit desired productivity applications and choose package sources.
- [ ] Add each approved optional application in a separate commit.
- [ ] Add Restic after defining repository and credential inputs.

- [ ] Apply the Vesper palette consistently across DMS shell surfaces and appearance settings.
- [ ] Document the initial Fedora custom online installation, including switching to a terminal with `Ctrl+Alt+Fn+F1` and manually installing the Wi-Fi firmware required after boot.
- [ ] Review and add managed Codex configuration while excluding credentials and runtime state.

## Priority 5: Setup observability

- [x] Report Nerd Font availability in `status`.
- [x] Report the default browser in `status`.
- [x] Report the login shell in `status`.
- [ ] Report the graphical login manager in `status`.
- [ ] Report all managed configuration links in `status`.
- [ ] Add a `doctor` command dispatcher.
- [ ] Add graphics and VA-API checks to `doctor`.
- [ ] Add audio and media-control checks to `doctor`.
- [ ] Add Bluetooth service and adapter checks to `doctor`.
- [ ] Add keyring, Secret Service, and Polkit checks to `doctor`.
- [ ] Add portal backend checks to `doctor`.
- [ ] Add niri, DMS, and Xwayland checks to `doctor`.
- [ ] Add keyd configuration and service checks to `doctor`.
- [ ] Add Docker, Mise, Node, Pi, Codex, and Herdr checks to `doctor`.

## Priority 6: Manual validation

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
- [ ] Validate one DMS process and no overlapping shell services.
- [ ] Validate keyd tap/hold behavior and TTY recovery.

## Priority 7: Automation and maintenance

- [ ] Add Bash syntax checks to CI.
- [ ] Add Zsh syntax checks to CI.
- [ ] Add ShellCheck to CI.
- [ ] Add whitespace and JSON/TOML validation to CI.
- [ ] Add niri configuration validation to CI where available.
- [ ] Document update commands for DNF, Flatpak, Homebrew, Mise, and Herdr.
- [ ] Document removal and rollback steps for external repositories.
- [ ] Document post-install next steps and print them when setup finishes, including `gh auth login` and `gh auth setup-git`.
