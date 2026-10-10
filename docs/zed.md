# Zed recovery

If native Wayland is unusable after diagnosis, try a one-off XWayland launch:

```bash
WAYLAND_DISPLAY="" ~/.local/bin/zed
```

If automatic updates fail, check that `rsync` is available. Setup preserves a
valid newer installation; rerunning setup is not a request to downgrade it.
Keep the previous managed bundle when replacing an installation so a failed
upgrade can be reverted.

Before reinstalling or removing Zed, close it and preserve native user data,
logs, and extensions under `~/.local/share/zed` and the XDG cache directory.
Managed configuration links point into this checkout; preserve their source
files. Remove Zed from managed setup before deleting its installation if you
want subsequent setup runs to leave it absent.
