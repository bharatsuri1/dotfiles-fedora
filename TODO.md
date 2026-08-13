# TODO

## Priority 1: Desktop experience

- [ ] Review generated DMS settings and identify portable defaults.
- [ ] Track minimal DMS application preferences.
- [ ] Tune niri touchpad scroll direction and speed.
- [ ] Tune niri touchpad acceleration and click behavior.
- [ ] Review niri touchpad gestures without adding a conflicting gesture daemon.
- [ ] Configure niri keyboard repeat delay and rate.
- [ ] Make new niri windows open full-width by default.
- [x] Add Nerd Font icons to the Starship prompt.
- [ ] Add a niri keybinding for the default Herdr session.
- [ ] Select a graphical login manager compatible with niri.
- [ ] Install and configure the selected graphical login manager.
- [ ] Preserve a TTY recovery path when enabling graphical login.

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
- [ ] Add tmux keybindings to create, rename, and switch sessions and windows.
- [ ] Add tmux keybindings to split panes.
- [x] Add repeatable tmux `h`, `j`, `k`, and `l` keybindings to navigate panes.
- [x] Add repeatable tmux `H`, `J`, `K`, and `L` keybindings to resize panes.
- [x] Bind tmux `x` to kill the active pane without confirmation.
- [x] Add a tmux keybinding to reload the managed configuration.
- [x] Enable vi-style tmux copy mode.
- [x] Copy tmux copy-mode selections with `wl-copy` on Wayland.
- [x] Link the managed tmux configuration during the `config` setup phase.
- [x] Reload the managed tmux configuration during setup when a tmux server is running.
- [ ] Report the managed tmux configuration link in `status`.
- [ ] Document tmux in the README managed scope.
- [ ] Validate the managed tmux configuration and setup scripts.
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

- [ ] Report Nerd Font availability in `status`.
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
