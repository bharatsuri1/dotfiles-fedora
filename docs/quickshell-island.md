# Quickshell center alcove

Status: MVP implemented; final live review pending. The shell renders a single
centered alcove with a clock and battery indicator. Its static silhouette
passed the first live review before the entrance motion was added.

## Design

The island begins at the display's top edge rather than floating below it. Its
top corners curve outward by 4 logical pixels across the first 8 pixels of
depth, creating a restrained lip before the sidewalls resolve into soft lower
corners. The rest of the top strip is transparent and does not accept pointer
input.

The surface is intentionally quiet:

- a fixed 250×34 logical-pixel silhouette prevents minute and percentage
  changes from resizing the island;
- a 12-hour clock and battery percentage use fixed measurement slots;
- the battery is an authored gauge, avoiding icon-font rendering differences;
- the gauge and percentage use an 8-pixel optical gap;
- charging changes only the battery treatment to Vesper green; and
- there are no shadows, borders, hover states, or continuous animation.

Geometry is centralized in `theme/Theme.qml`: `islandWidth`, `islandHeight`,
`topFlareWidth`, `topFlareDepth`, `cornerRadius`, and `contentGap` define the composition.
`island/CenterIsland.qml` owns the shape and content.

The only motion is a 360 ms `OutExpo` entrance from the top edge when the shell
starts or reloads. Shape and content move as one object; content resolves after
the surface is already legible. Setting `motionEnabled` to `false` renders the
finished state immediately, without an opacity-hidden first frame.

## Runtime model

`shell.qml` creates one transparent `PanelWindow` per Quickshell screen. Each
window reserves only the island's 34-pixel height and limits its input mask to
the island bounds. The clock uses `SystemClock` at minute precision. Battery
state comes from the event-driven `UPower.displayDevice`; machines without a
laptop battery show only the clock.

The whole `config/quickshell/` directory is linked to
`~/.config/quickshell` by `fedora-setup config`. The setup helper backs up an
existing destination before replacing it, so applying the managed directory is
idempotent and recoverable.

## Validation

Static checks:

```bash
bash -n bootstrap.sh bin/fedora-setup lib/fedora-setup/*.sh \
  lib/fedora-setup/fonts/*.sh
git diff --cached --check
./bin/fedora-setup --help
./bin/fedora-setup --dry-run config
```

Live review must confirm the exact staged configuration at the laptop's 1.5×
scale: top-edge attachment, flare continuity, lower-corner curvature,
optical centering, type rendering, battery fill, fullscreen behavior, and a
clean Quickshell journal. External and multi-monitor outputs remain required
validation.

## Transient OSD (volume / brightness)

The island has an explicit presentation mode: `idle`, `hover`, or `osd`. A
detected system change — volume/mute from the default PipeWire sink, or screen
brightness from an inotify watch on the sysfs backlight file — calls
`showOsd(kind, value, muted)`, which claims the island: the silhouette morphs
to a shorter, wider pill (`islandOsdScaleW` × `islandOsdScaleH`), the clock,
battery row, and hover control buttons hide, and a single row shows an icon,
a display-only slider, and a fixed-width percent.

A dwell timer (`osdDwellMs`, 1.4 s) holds the OSD and resets on every change;
on timeout the island returns to hover if the pointer is still inside,
otherwise idle. Mute swaps the speaker glyph (`\ueee8`), dims and drains the
track, and shows `0%`. Brightness uses `\uf522` and always shows the real
percent. Writers stay external (niri `wpctl`/`brightnessctl` keybinds); the
island only observes, and both providers are event-driven (PipeWire signals,
sysfs inotify) with a 2 s startup suppression window so shell reloads never
flash an OSD.

## Next slice

Any future state transition must inherit this geometry, use a complete
reduced-motion path, and justify occupying permanent attention. Media,
notifications, network, Bluetooth, workspace context, and further expansion
remain out of scope.

## Rollback

Stopping `quickshell.service` removes only the cosmetic surface. Fuzzel, niri,
Mako, Swayidle, gtklock, policy prompts, and portals remain independent. To
restore a prior user-owned Quickshell directory, remove the managed symlink and
move its timestamped copy back from the setup backup directory.
