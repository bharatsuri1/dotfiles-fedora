# Screenshot troubleshooting

If region selection is stuck, invoke the region capture again to dismiss it.
Canceling selection should leave no capture behind.

If Tensaku cannot open a saved capture, check the output path. Its Flatpak has
home access, while `/tmp` refers to its private sandbox. Keep custom capture
locations inside the home directory.

If the clipboard is empty after annotation, verify `wl-copy` is available and
that Tensaku saved the edited file before exiting. The host wrapper copies that
file after the editor closes.

## Capture privacy

Grim uses wlr-screencopy. A Niri rule that blocks only `screencast` does not
necessarily hide content from third-party screenshot tools. Use
`block-out-from "screen-capture"` for windows that must also be hidden from Grim.

## Recovery

Niri's native `screenshot`, `screenshot-screen`, and `screenshot-window`
actions remain an alternative if the external workflow fails. Restore those
bindings in the Niri config and validate before reloading.

Tensaku can be removed with `flatpak uninstall --user dev.tensaku.Tensaku`
without deleting saved screenshots. The setup screenshots phase can reinstall it.
