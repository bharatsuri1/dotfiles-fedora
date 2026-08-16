# Screenshots

The managed screenshot workflow uses `grim`, `slurp`, `wl-copy`, and the
repository's pinned Tensaku Flatpak bundle. It is designed for the niri Wayland
session and keeps niri's native screenshot interface as a fallback.

## Workflow

`take-screenshot` accepts `region`, `screen`, or `window`. Region capture uses
slurp and grim. Screen and window capture use niri's compositor-aware actions.
Every successful capture is written to disk and copied to the Wayland
clipboard. The completion notification includes an **Edit** action that opens
the saved image in Tensaku.

Use `--edit` to open Tensaku immediately:

```bash
take-screenshot region --edit
take-screenshot screen --edit
take-screenshot window --edit
```

Tensaku starts with the arrow tool. Enter copies the annotated image, saves it
over the original capture, and exits. The host wrapper then copies the saved
file with `wl-copy`, keeping the clipboard available after the Flatpak exits.
Escape closes Tensaku without changing the original capture.

## Output directory

The default is the `Screenshots` subdirectory of `XDG_PICTURES_DIR`, falling
back to `~/Pictures/Screenshots`. Override it for the session with:

```bash
export DOTFILES_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Keep the override inside the home directory. The Tensaku Flatpak has home
access, but paths such as `/tmp` refer to the Flatpak's private sandbox and
cannot be opened by the editor.

The directory is created on the first successful invocation. Canceling slurp
does not leave an empty file or notification behind. Pressing the region binding
again while slurp is active dismisses the selector.

## Managed Tensaku bundle

The setup installs `assets/tensaku-v0.26.6.flatpak` into the per-user Flatpak
installation. This supplied bundle targets x86-64 and has SHA-256 checksum:

```text
a38d6b29c62916791305842d1ee066b580f1d7063c3f9182faad79c081c2a423
```

The setup verifies both the bundle checksum and installed Flatpak commit. To
upgrade Tensaku, replace the versioned artifact and update its version,
checksum, and expected commit in `lib/laptop-setup/screenshots.sh`.

Tensaku's configuration is managed read-only at `config/tensaku/config.toml`.
Change preferences in the repository rather than through Tensaku's preferences
dialog so rerunning the setup remains deterministic.

## Privacy

Region capture through grim uses the wlr-screencopy protocol. Niri window rules
that only use `block-out-from "screencast"` do not necessarily protect content
from third-party screenshot tools. Sensitive windows should use
`block-out-from "screen-capture"` when they must also be hidden from grim.

No screen-freezing overlay is used. This avoids transformed-output bugs and
prevents a third-party frozen preview from becoming another capturable surface.

## Rollback

Restore native capture actions in `config/niri/config.kdl` by binding the
preferred keys to `screenshot`, `screenshot-screen`, and `screenshot-window`.
Tensaku can be removed without touching saved images:

```bash
flatpak uninstall --user dev.tensaku.Tensaku
```

The repository artifact remains available for a later `laptop-setup screenshots`
run.
