# DMS removal and bare-niri transition record

Status: completed and verified on 2026-08-13.

## Outcome

The machine now boots to `multi-user.target` and starts the graphical desktop
manually through `niri-session`. The tested baseline is independent of DMS:

| Concern | Owner |
| --- | --- |
| Compositor/session | niri through `niri-session` |
| Launcher | Fuzzel (`Mod+Space`) |
| Notifications | Mako |
| Lock screen | Swaylock (`Mod+Shift+L`) |
| Idle and lock-before-sleep | Swayidle |
| Polkit prompts | LXQt PolicyKit agent |
| Portals | GNOME and GTK portal backends |
| X11 compatibility | Xwayland Satellite |
| Display configuration | Repository-owned niri KDL |
| Graphical login | None; TTY login is the recovery baseline |
| Bar/status | None until the custom Quickshell shell |

The final reboot audit confirmed:

- DMS, DMS CLI, DMS Greeter, Quickshell, greetd, and greetd-selinux are absent;
- the AvengeMedia DMS and Dank Linux COPRs are disabled;
- no DMS process, service, niri dependency, configuration reference, generated
  state, cache, greeter artifact, or obsolete backup remains;
- DMS Greeter's named ACLs and user group membership were removed;
- niri, Fuzzel, Mako, Swayidle, Swaylock, LXQt PolicyKit, portals, media keys,
  brightness controls, screenshots, clipboard integration, and Xwayland were
  validated from a TTY-started session before and after reboot; and
- rerunning `laptop-setup apply` cannot reinstall or reattach DMS.

## Migration decisions

DMS had combined three independently important concerns: desktop-shell UI,
DMS-written niri settings, and graphical login through DMS Greeter. The removal
therefore used staged TTY and reboot gates instead of treating the DMS RPM as
the entire integration.

The durable design rules are:

- niri must remain usable when every optional shell surface fails;
- Fuzzel remains a deterministic emergency launcher;
- each baseline service has one explicit owner and one niri-session startup
  path;
- normal setup may install and configure the baseline but must never silently
  uninstall packages or switch the display manager;
- a future graphical login manager must not depend on the desktop shell; and
- a future Quickshell process may replace the bar, launcher, and eventually
  notifications only after it satisfies each complete service contract.

## Retained requirements

The one-time DMS settings review retained only portable requirements:

- internal display `eDP-1` uses `2560x1600@120.002`, scale `1.5`, at `0,0`;
- the future launcher remains keyboard-first and closes niri's overview when it
  opens;
- the custom shell should expose workspace index, focused-window context,
  clock, media, system tray, battery percentage, notifications, and system
  controls;
- the Vesper palette is authoritative, with 12-pixel rounded geometry,
  regular-weight UI typography, 12-hour time, and restrained animations as
  initial design defaults;
- low and normal notifications time out after five seconds while critical
  notifications remain until dismissed; and
- idle, display power, suspend, and lock-before-suspend policy must remain
  explicit rather than inheriting DMS defaults.

Generated recent-window, four-pixel layout-gap, window-rounding, and
wallpaper-blur fragments were not effective parts of the managed configuration
and were not migrated.

## Export record

Before removal, DMS configuration, state, themes, notepad data, and generated
niri fragments were exported outside Git to
`~/.local/state/dotfiles-fedora/migrations/dms-20260813`. The source and export
copies of `settings.json` and `outputs.kdl` were checksum-verified. The only
notepad document was empty. Clipboard, notification, cache, and usage history
were not treated as portable configuration.

The export is intentionally not managed by this repository. It can be removed
manually when no further rollback reference is wanted.

## Launcher and shell direction

Fuzzel was selected for the recovery baseline because it is small and has few
failure modes. Rofi provides deeper selection-interface theming, while
Walker/Elephant provides richer ready-made providers at the cost of another
persistent framework. A repository-owned Quickshell launcher has the highest
visual ceiling and can share a design system with the planned floating island,
but also has the highest ownership cost.

The target remains:

```text
niri
  + repository-owned Quickshell island and launcher
  + explicit replaceable providers and services
  + Fuzzel retained as an emergency launcher
```

A Quickshell frontend over Elephant remains an investigation rather than a
committed architecture until packaging, IPC, lifecycle, latency, and failure
behavior have been demonstrated.
