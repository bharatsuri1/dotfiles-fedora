# DMS removal and bare-niri transition plan

Status: repository migration complete; machine removal has not started.

On 2026-08-13, DMS configuration, state, themes, notepad data, and generated
niri fragments were exported outside Git to
`~/.local/state/dotfiles-fedora/migrations/dms-20260813`. The source and exported
copies of `settings.json` and `outputs.kdl` were checksum-verified. The only
notepad document was empty. Cache data, clipboard history, notification history,
and usage history were deliberately excluded from the portable migration set.

## Decision

Return the machine to a DMS-free, independently managed niri baseline before
building a custom shell. The baseline must remain usable without Quickshell:
niri owns composition and window management, Fuzzel temporarily owns launching,
and small explicit components own notifications, locking, authorization, and
other desktop services.

After that baseline is proven, a repository-owned Quickshell project may add the
floating island and a polished launcher. It must remain an optional layer: niri
must still start and provide a recovery-capable session if Quickshell fails.

This deliberately separates three concerns that DMS currently bundles:

1. The desktop shell (`dms.service`).
2. DMS-written niri settings and launcher bindings.
3. Graphical login (`greetd` running `dms-greeter`).

Removing only the `dms` RPM would leave the other two concerns broken or still
DMS-owned. They must be migrated in a controlled order.

## Conversation review

The final shared-chat discussion compared Fuzzel, Rofi, Walker/Elephant, and a
custom Quickshell launcher.

- Fuzzel is the smallest and cleanest recovery/baseline launcher, but its visual
  ceiling is below the desired polished, animated experience.
- Rofi has mature and unusually deep theming, but remains fundamentally a
  selection interface rather than arbitrary application UI.
- Walker plus Elephant provides the richest ready-made provider experience, at
  the cost of another higher-level framework and a persistent backend.
- A custom Quickshell launcher has the highest visual ceiling and can share one
  design system with the floating island. It also carries the highest ownership
  and implementation cost.
- A Quickshell frontend over Elephant is worth a spike, but should not become the
  committed architecture until IPC compatibility, packaging, lifecycle,
  latency, and failure behavior have been demonstrated.

The resulting direction is:

```text
recovery baseline
  niri + Fuzzel + small desktop services

target desktop
  niri
    + repository-owned Quickshell island and launcher
    + explicit replaceable providers/services
    + Fuzzel retained as an emergency launcher
```

Quickshell is a toolkit, not a ready-made replacement for every facility DMS
provides. The custom project must name the owner of each function rather than
silently inheriting DMS assumptions.

## Observed state on 2026-08-13

This inventory was collected read-only from the current machine.

- `niri-26.04` is installed and is a Fedora Project build.
- `dms`, `dms-cli`, and `dms-greeter` 1.5.3 are installed from the AvengeMedia
  COPR.
- `quickshell` 0.3.0 is installed from the AvengeMedia COPR and is currently
  required by both `dms` and `dms-greeter`. There is no custom Quickshell config.
- `greetd` is enabled and active, `graphical.target` is the default, and
  `/etc/greetd/config.toml` launches `/usr/bin/dms-greeter` under the `greeter`
  account.
- `dms.service` is active and enabled. In addition,
  `~/.config/systemd/user/niri.service.wants/dms.service` makes niri explicitly
  pull it into the session.
- DMS currently owns `org.freedesktop.Notifications`; no Mako or SwayNC package
  is installed.
- The managed niri config binds `Mod+Space` to DMS Spotlight and includes
  `~/.config/niri/dms/outputs.kdl`.
- DMS generated output state for `eDP-1`: `2560x1600@120.002`, scale `1.5`, at
  position `0,0`. This must be preserved in repository-owned niri config before
  deleting DMS data.
- Other generated DMS fragments currently contain recent-window, layout,
  rounded-window, and blur rules. Only `outputs.kdl` is included by the managed
  config, so those other fragments are not part of the effective repo-owned
  configuration.
- The greeter sync added the user to the `greeter` group, added `greeter`
  traversal ACLs to home/config/state/cache paths, changed DMS directories to
  the `greeter` group, and placed symlinks under `/var/cache/dms-greeter`.
- DMS user data exists under `~/.config/DankMaterialShell`,
  `~/.local/state/DankMaterialShell`, and `~/.cache/DankMaterialShell`.
- The DMS state includes a notepad file. It must be reviewed/exported before
  cleanup rather than deleted blindly.
- Fuzzel, Waybar, and Swaylock are already installed. A graphical Polkit agent
  and a standalone notification daemon are not currently installed.
- Portals and Xwayland Satellite are already independent of DMS and should be
  retained.

## Target ownership

| Concern | Bare-niri owner | Later custom owner |
| --- | --- | --- |
| Compositor/session | `niri-session` | unchanged |
| Launcher | Fuzzel (`Mod+Space`) | custom Quickshell; Fuzzel fallback retained |
| Bar/status | none or minimal Waybar | custom Quickshell island |
| Notifications | Mako or another reviewed daemon | custom Quickshell only after it implements the full notification contract |
| Lock screen | Swaylock | custom UI may invoke it, but authentication remains separate |
| Polkit prompts | reviewed standalone agent | unchanged unless deliberately replaced |
| Portals | existing GNOME/GTK portal stack | unchanged |
| X11 compatibility | Xwayland Satellite | unchanged |
| Display configuration | repository-owned niri KDL | unchanged |
| Graphical login | explicit later decision | must not depend on desktop-shell DMS |

## Retained migration requirements

The one-time settings review retained these portable requirements without
checking DMS application state into Git:

- Preserve the internal display at `2560x1600@120.002`, scale `1.5`, position
  `0,0`; this now lives directly in the managed niri configuration.
- Keep a keyboard-first list launcher, with `Mod+Space` opening Fuzzel for the
  baseline and closing niri's overview when the future shell launcher opens.
- Preserve visible workspace index, focused-window context, clock, media,
  system tray, battery percentage, notifications, and control-center access as
  requirements for the future shell rather than copying DMS settings.
- Use 12-hour time, 12-pixel rounded geometry, regular-weight UI typography,
  and restrained animations as initial design defaults. The existing repository
  Vesper palette remains authoritative; DMS's Catppuccin theme is reference
  material only.
- Notifications should appear for five seconds at low/normal urgency and remain
  until dismissed at critical urgency. Privacy redaction was disabled.
- DMS did not own an active idle-lock policy: AC and battery lock/monitor
  timeouts were zero and lock-before-suspend was disabled. Ticket 3 must choose
  those owners explicitly instead of inheriting these unsafe defaults.
- The generated recent-window radius, four-pixel layout gap, window rounding,
  and wallpaper-blur layer were not effective includes in the managed config
  and were not migrated. They remain available only in the external export.

## Preconditions

Do not begin removal until all of these are true:

- A TTY login and `niri-session` startup have been tested.
- A second TTY is available during the transition.
- The generated `eDP-1` output configuration has been copied into a managed,
  DMS-independent file and validated with `niri validate`.
- `Mod+Space` launches Fuzzel, and terminal/file/browser bindings work.
- A notification daemon, lock command, and graphical Polkit agent have been
  selected, installed, started independently of DMS, and tested.
- Any wanted DMS notes/settings have been exported to a neutral backup.
- The repository no longer installs or enables DMS when `apply` is rerun.
- The exact effect of `dms greeter uninstall` has been previewed from its status,
  backups, and current documentation; its restore target is known.

## Planned transition sequence

Commands below are documentation for a future supervised run. They have not
been run.

### 1. Make the repository DMS-independent

- Remove the DMS phase from `apply`, the command dispatcher, and module loading.
- Stop enabling `avengemedia/dms` from both the niri and DMS setup phases. Keep
  niri installed from Fedora's repositories.
- Replace the DMS Spotlight binding with `spawn "fuzzel"`.
- Move the current output block into repository-owned niri configuration and
  remove `include "dms/outputs.kdl"`.
- Add explicit managed startup/configuration for the selected notification
  daemon and Polkit agent. Keep Swaylock directly callable from niri.
- Remove DMS and DMS Greeter assumptions from `status`, README instructions,
  and the login-manager workflow.
- Add a dedicated migration/removal command only if it can be dry-run, audited,
  and made idempotent. Normal `apply` must never silently uninstall packages or
  switch the display manager.

Validate the new config before touching the live session:

```bash
niri validate --config ./config/niri/config.kdl
./bin/laptop-setup --dry-run apply
```

### 2. Prove the bare session before uninstalling packages

From the current session, remove the explicit niri-to-DMS dependency for the
next login, without stopping the currently running shell mid-session:

```bash
systemctl --user remove-wants niri.service dms.service
systemctl --user disable dms.service
systemctl --user daemon-reload
```

Then log out and start `niri-session` from a TTY. Confirm that niri, Fuzzel,
notifications, locking, Polkit, portals, screenshots, media keys, brightness,
and Xwayland applications all work. If the baseline fails, return to the prior
session and fix it before package removal.

Do not use `systemctl --user disable --now dms` from inside the only graphical
session as the first step: DMS currently provides visible shell surfaces and
notifications, so stopping it immediately makes diagnosis harder.

### 3. Decouple graphical login

This step is separate from the shell removal.

For the strictest bare-niri baseline, return to TTY login:

1. Run the vendor-supported `dms greeter uninstall` while the DMS CLI still
   exists. Its stated purpose is to disable greetd, remove DMS-managed greeter
   configuration, and restore the pre-DMS-greeter state.
2. Verify `greetd.service` is disabled/inactive, `display-manager.service` no
   longer resolves to DMS greetd configuration, and the boot default is
   `multi-user.target` if TTY boot is the intended result.
3. Reboot once and prove TTY login followed by `niri-session` before removing
   the packages.

Future alternatives are a plain greetd greeter or another display manager, but
that is a separate design decision. Do not merely uninstall `dms-greeter` while
enabled: the current greetd command points directly to its binary.

Expected supervised command:

```bash
dms greeter uninstall --yes
```

### 4. Remove packages and repositories

First inspect the DNF transaction; accept it only if it retains niri, portals,
Xwayland Satellite, the selected notification daemon, lock screen, Polkit agent,
and other baseline components.

```bash
sudo dnf remove dms dms-cli dms-greeter
```

Then decide Quickshell separately:

- Remove it for a literal minimal baseline if no custom shell exists yet.
- Keep it only as a development dependency for the repository-owned shell.

Likewise, retain `greetd` only if a non-DMS greeter configuration has been
deliberately selected. Otherwise remove `greetd` and `greetd-selinux` after the
TTY boot has been proven.

Once no installed package relies on them, disable the `avengemedia/dms` and
`avengemedia/danklinux` COPRs. Preview this carefully because the latter appears
as a runtime dependency repository of the former.

### 5. Clean DMS-owned user and greeter state

Only after exporting wanted content and proving the replacement session, remove:

```text
~/.config/DankMaterialShell
~/.local/state/DankMaterialShell
~/.cache/DankMaterialShell
~/.config/niri/dms
~/.config/systemd/user/niri.service.wants/dms.service
/var/cache/dms-greeter
/etc/greetd/niri/dms.kdl and DMS-created backups, if not removed by the vendor tool
```

Also audit and reverse the greeter sync's security changes:

- remove the user's membership from the `greeter` group if no remaining greeter
  uses it;
- remove only the named `greeter` ACL entries that DMS added to the traversed
  home/config/cache/state directories;
- restore user ownership/group on any retained files;
- remove the `greeter` account/group only when package removal and system-user
  ownership checks show nothing else needs them.

Do not recursively reset permissions across the home directory. Remove only
the exact ACL entries and group ownership established by the greeter sync.

### 6. Validate absence and recovery

The transition is complete only when all of these pass after a reboot:

```text
- no dms, dms-cli, or dms-greeter RPM is installed
- no DMS COPR is enabled
- no dms process or user unit is loaded/running/enabled
- no niri config references dms or ~/.config/niri/dms
- no greetd command references dms-greeter
- no DMS data/cache or greeter-cache symlink remains
- niri starts through niri-session from the chosen login path
- terminal, Fuzzel, notifications, locking, Polkit, portals, media keys,
  brightness, screenshots, and Xwayland work
- rerunning laptop-setup does not reinstall or reattach DMS
```

## Rollback boundaries

- Before package removal: restore the previous niri config and re-add
  `dms.service` as a want of `niri.service`.
- After greeter uninstall but before package removal: use the DMS greeter tool's
  install/sync/enable path only if returning to DMS is intentional.
- After package removal: reinstalling DMS is a new deployment, not a reliable
  rollback. Preserve exported settings separately if that possibility matters.
- Always retain the TTY path; a shell or greeter failure must not prevent login.

## Custom Quickshell follow-up

The first custom milestone should be a small, disposable shell that proves:

- one systemd user service and one startup owner;
- niri IPC event handling without polling;
- a launcher with application discovery, keyboard navigation, focus handling,
  and deterministic failure fallback to Fuzzel;
- notification ownership without conflicting D-Bus services;
- monitor hotplug, scaling, fullscreen, lock-screen, and restart behavior;
- bounded resource use and journal-visible failures.

Only after that should the floating-island states, rich launcher providers,
animations, clipboard history, file search, or an Elephant integration be added.
The Elephant hybrid remains an investigation, not the default architecture.
