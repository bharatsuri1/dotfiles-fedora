# Dictation permissions and recovery

## Input access

Setup grants `input` group membership for Voxtype's evdev cancellation listener.
This permits reading keyboard events beyond dictation controls. Membership
changes require logout or reboot. Escape still reaches the focused application,
so cancellation may also dismiss its dialog.

If you no longer need evdev access, first check whether another tool requires it,
then remove membership with `sudo gpasswd --delete "$USER" input` and log out.

## Troubleshooting

```bash
voxtype status
voxtype setup check
systemctl --user status voxtype.service
journalctl --user -u voxtype.service -b
```

| Problem | Check |
| --- | --- |
| Recording does not start | Service activity, loaded Niri config, and default microphone in `wpctl status` |
| Escape does not cancel | `id -nG`; log out after input-group changes |
| Text is not available | Output mode in the managed config; clipboard mode requires manual paste |
| Missing model | Rerun the Voxtype setup phase; preserve any unrecognized existing model |
| Stuck recording | `voxtype record cancel`, then restart the user service if needed |
| Repeated crashes | Journal errors and installed binary verification via setup status |

For an offline check, disconnect networking and transcribe a short phrase.
Avoid sharing logs containing speech or private device details.

## Data preservation

Model weights and optional meeting exports live under `~/.local/share/voxtype/`.
Keep these when stopping or replacing the daemon. Runtime state under
`$XDG_RUNTIME_DIR/voxtype/` is temporary; service logs are in the user journal.
The configuration symlink points into this checkout: changing its target changes
managed defaults, not just the local installation.

## Disable or restore

Stop the daemon and detach it from future Niri sessions:

```bash
systemctl --user stop voxtype.service
rm -f ~/.config/systemd/user/niri.service.wants/voxtype.service
systemctl --user daemon-reload
```

Reapplying setup restores the attachment. To restore operation immediately,
start the user service from a graphical session. For full removal, remove the
Voxtype entries from managed setup and Niri config before deleting its installed
binaries and linked config/unit. Preserve models and exports until you explicitly
choose to discard them; remove `wtype` only if no other tool needs it.

When changing a pinned release, verify the installed binary against the previous
pin and move it aside before applying the new pin. The installer refuses to
replace an unrecognized artifact. Keep the previous binary for rollback.
