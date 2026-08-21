# Local speech-to-text (Voxtype)

The `voxtype` phase installs a privacy-first, fully local dictation workflow for
the Fedora/niri laptop. Recording starts only on an intentional niri binding,
transcription runs on-device with Whisper, and text is inserted into the focused
application through `wtype` when possible.

This surface is independent of Quickshell. A future command-center UI may show
daemon state or launch `voxtype configure`, but this phase does not add
Quickshell widgets.

## Decision record

| Candidate | Version evaluated | License | Packaging | Fedora/niri fit | Decision |
| --- | --- | --- | --- | --- | --- |
| [Voxtype](https://github.com/peteonrails/voxtype) | 0.7.5 | MIT | Signed GitHub release binaries, Fedora RPM, AppImage | Wayland-first; explicit `record start`/`stop`/`toggle`/`cancel`; compositor toggle plus state-aware evdev cancellation; local Whisper default | **Adopted** |
| [Handy](https://github.com/cjpais/Handy) | 0.9.5 | MIT | Tauri GUI RPM/AppImage/deb with update signatures | Cross-platform GUI; Wayland typing needs `wtype`/`dotool`; global shortcuts on Wayland must still be compositor-owned; overlay can steal focus on some compositors | Rejected for this laptop |

### Decision matrix

| Criterion | Voxtype 0.7.5 | Handy 0.9.5 |
| --- | --- | --- |
| Local-only default | Yes (`whisper.mode = "local"`) | Yes |
| Dictation accuracy | Whisper `base.en` is acceptable for short English notes; larger models optional | Whisper / Parakeet models |
| First-result latency | Model kept loaded by the user daemon; short clips on AVX2 CPU | Comparable local Whisper cost plus Tauri GUI overhead |
| CPU / memory | Single Rust daemon; no GUI shell required | Tauri/WebView settings UI always present |
| Model size (default) | `base.en` ≈ 142 MB under `~/.local/share/voxtype/models/` | User-selected Whisper/Parakeet downloads |
| Wayland insertion | `wtype` primary, clipboard fallback | `wtype` / `dotool` / enigo; Linux overlay focus caveats |
| niri keybinding support | First-class `voxtype record toggle` / `cancel` commands | CLI toggle flags exist; less Linux/compositor-native packaging story |
| Accessibility | Keyboard-driven daemon; optional notifications and audio cues | GUI settings plus shortcuts |
| Packaging trust | SHA-256 sums and detached signatures on GitHub releases | Update `.sig` files on releases |
| Updates | Pin bump in this repository after verification | App-managed updater or manual package replace |
| Logs / history | Journald unit logs; meetings optional and local | App history UI |
| Rollback | Remove binary, unit, bindings, optional model tree | Remove RPM/AppImage and config |

Handy remains a reasonable cross-platform choice, but Voxtype matches this
repository's recovery-friendly and minimal-daemon preferences. niri owns the
intentional `Hyper+S` toggle. Voxtype observes bare `Escape` through evdev so it
can cancel only while dictation is active; this deliberately requires permanent
`input` group membership and is documented as the security cost of the chosen
interaction.

## Ownership

| Component | Owner | Location |
| --- | --- | --- |
| Binary | This repository (pinned upstream artifact) | `~/.local/bin/voxtype` |
| OSD frontend | This repository (pinned upstream artifact) | `~/.local/bin/voxtype-osd-gtk4` |
| Runtime typing backend | Fedora/DNF | `wtype` |
| OSD layer-shell library | Fedora/DNF | `gtk4-layer-shell` |
| Clipboard fallback | Desktop foundation | `wl-clipboard` (`wl-copy`) |
| Audio capture | Desktop foundation | PipeWire + `pipewire-alsa` |
| Managed config | This repository | `config/voxtype/config.toml` → `~/.config/voxtype/config.toml` |
| User systemd unit | This repository | `config/systemd/user/voxtype.service` attached to `niri.service` |
| niri toggle binding | This repository | `config/niri/config.kdl` |
| Escape cancel listener | Voxtype evdev listener | `/dev/input/event*` through the `input` group |
| Model weights | This repository pins metadata; file remains user data | `~/.local/share/voxtype/models/` |
| Runtime state | User runtime (not in Git) | `$XDG_RUNTIME_DIR/voxtype/` |
| Optional meetings / caches | User data (not in Git) | under `~/.local/share/voxtype/` and cache dirs |

### Managed binary

| Architecture | Asset | SHA-256 |
| --- | --- | --- |
| x86_64 | `voxtype-0.7.5-linux-x86_64-avx2` | `18ae0510d0c964689f8c9b7119c0b9a45569985e82977dc4f1ef4d76fddd887c` |
| aarch64 | `voxtype-0.7.5-linux-aarch64-cpu` | `bf72fbfaae1f4720c25ee0a8e75ec381f6b7811b1e810d80dfb9207f4ebc2e4c` |
| x86_64 | `voxtype-0.7.5-linux-x86_64-osd-gtk4` | `fed81695551cee95bb0fd376ec6dc49638b0fd714480504d78aa597b006a5952` |

The OSD frontend (`voxtype-osd-gtk4`) is only published for x86_64 in 0.7.5; on aarch64 the setup phase skips it and the waveform OSD is unavailable.

The upstream Fedora RPM was not selected as the install path because it is a
multi-hundred-megabyte bundle of every binary variant. The pinned AVX2/CPU
binary matches the device-controls pattern, stays under `~/.local/bin`, and is
checksum-verified before install. An existing `~/.local/bin/voxtype` with a
different checksum is never overwritten.

## Default model

| Setting | Value |
| --- | --- |
| Engine | Whisper (local) |
| Model | `base.en` |
| File | `~/.local/share/voxtype/models/ggml-base.en.bin` |
| Approx. size | 142 MB |
| Language | English |
| Source revision | `ggerganov/whisper.cpp@5359861c739e955e79d9a303bcbc70fb988958b1` |
| SHA-256 | `a03779c86df3323075f5e796cb2ce5029f00ec8869eee3fdfb897afe36c6d002` |

`base.en` is the conservative laptop default: small enough for a 16 GiB system,
fast enough for short dictations on an AVX2 CPU, and accurate enough for notes
and chat. Larger models (`small.en`, `medium.en`, `large-v3-turbo`) and ONNX
engines remain optional via `voxtype setup model` / upstream docs and are not
managed by this repository.

## Privacy behavior

- Local Whisper is the default. The managed config sets `whisper.mode = "local"`.
- No cloud account or API key is required for the default workflow.
- Remote Whisper endpoints, LLM post-processing pipes, and cloud engines require
  an explicit edit outside the managed defaults and are undocumented as part of
  the supported path.
- Notifications report recording start/stop only. Transcribed text is not shown
  in notifications.
- A floating waveform OSD (`voxtype-osd-gtk4`) replaces the start/stop
  notifications while recording. It shows only the live audio level meter, never
  dictated text.
- Audio feedback uses the subtle theme so recording state is audible without
  logging speech content.
- Models, temporary audio, meetings, and caches stay in XDG locations and must
  never be committed.

To verify local-only operation after install:

```bash
grep -E 'mode|remote_' ~/.config/voxtype/config.toml
# Disconnect the network, then:
voxtype record toggle   # or Hyper+S
# Speak a short phrase, toggle again, confirm insertion still works.
```

## Install

Preview or apply only this phase:

```bash
./bin/fedora-setup --dry-run voxtype
./bin/fedora-setup voxtype
```

The phase:

1. Installs `wtype` and `gtk4-layer-shell` from Fedora if missing.
2. Downloads and SHA-256-verifies the pinned Voxtype binary into `~/.local/bin`.
3. Links the managed config and user systemd unit.
4. Adds the current user to `input` for Voxtype's evdev `Escape` listener. This
   takes effect after logout or reboot.
5. Downloads `base.en` from a pinned upstream revision and verifies its SHA-256.
   An existing model with a different digest is never overwritten.
6. Attaches `voxtype.service` to `niri.service` and restarts it when a graphical
   session is active.

`./bin/fedora-setup config` also relinks the managed Voxtype config, unit, and
niri bindings so configuration updates stay idempotent after the binary exists.

## Bindings

niri does not expose key-release binds, so the managed workflow uses toggle mode
instead of hold-to-talk. Binding bare `Escape` in niri would consume it in every
application, even while Voxtype is idle, so cancellation is state-aware inside
Voxtype instead.

| Binding | Action |
| --- | --- |
| `Hyper+S` | Toggle recording / stop and transcribe |
| `Escape` | Cancel the in-flight recording or transcription |

`Hyper` is Caps held via keyd and arrives in niri as `Ctrl+Alt+Super+Shift`.
Voxtype's evdev listener observes `Escape`; niri does not bind or consume it.
The event still reaches the focused application, so cancelling can also dismiss
an application dialog. Reading evdev requires the `input` group, which grants
access to keyboard events beyond Voxtype's two managed controls. This is an
intentional tradeoff for state-aware bare-`Escape` cancellation.

## Daily use

1. Ensure a niri graphical session is running so `voxtype.service` is active.
2. Focus a text field.
3. Press `Hyper+S`, speak, press `Hyper+S` again.
4. Text is typed at the cursor through `wtype`. If typing fails, Voxtype falls
   back to the clipboard and leaves a notification path via the daemon logs.
5. Press `Escape` to discard an in-progress take.

Useful commands:

```bash
voxtype status
voxtype setup check
systemctl --user status voxtype.service
journalctl --user -u voxtype.service -f
voxtype record toggle
voxtype record cancel
```

## Model switching

```bash
# Interactive picker (downloads into ~/.local/share/voxtype/models/)
voxtype setup model

# Non-interactive example
voxtype setup --download --model small.en
```

After changing models, update `whisper.model` in the managed config only if this
repository should own the new default; otherwise keep a local override outside
the symlink or accept that the next `config`/`voxtype` run restores `base.en`.

Preferred approach for temporary experiments:

```bash
voxtype record start --model small.en
# ... speak ...
voxtype record stop
```

## Data locations and retention

| Path | Contents | Retention |
| --- | --- | --- |
| `~/.local/bin/voxtype` | Pinned binary | Replaced only by a deliberate pin bump |
| `~/.config/voxtype/config.toml` | Managed symlink | Owned by this repository |
| `~/.local/share/voxtype/models/` | Model weights | Kept until manually removed |
| `~/.local/share/voxtype/meetings/` | Optional meeting exports | User-managed; unused by the default workflow |
| `$XDG_RUNTIME_DIR/voxtype/` | Daemon state file | Cleared on logout/reboot |
| `journalctl --user -u voxtype` | Service logs without transcript bodies by default | System journal vacuum policy |

No model weights, recordings, or transcripts are tracked in Git.

## Status and doctor checks

`./bin/fedora-setup status` reports:

- `wtype` package presence
- pinned binary checksum
- pinned OSD frontend (`voxtype-osd-gtk4`) checksum
- managed config and unit link state
- niri attachment and unit activity
- default model checksum
- insertion backend and clipboard fallback
- PipeWire activity and a resolvable default microphone source
- niri `Hyper+S` and Voxtype `Escape` configuration
- required `input` group membership

Voxtype's own checker is also available:

```bash
voxtype setup check
```

Neither status path prints dictated text.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Binding does nothing | `systemctl --user status voxtype.service`; confirm niri loaded the managed config (`niri validate` / reload) |
| `Escape` does not cancel | Confirm `id -nG` includes `input`; log out or reboot after the setup phase adds membership |
| No text inserted | Install/verify `wtype`; confirm focus is in a text field; check `voxtype setup check` output chain |
| Only clipboard fallback works | Some Flatpak or sandboxed fields reject virtual keyboards; paste manually once, or use a native field |
| No microphone | `wpctl status`, `systemctl --user status pipewire.service wireplumber.service`, desktop privacy settings |
| Missing model | `./bin/fedora-setup voxtype` or `voxtype setup --download --model base.en` |
| Stuck recording | `voxtype record cancel`, then `systemctl --user restart voxtype.service` |
| Daemon crash loop | `journalctl --user -u voxtype.service -b`; ensure the binary checksum still matches the pin |

## Updates

1. Review the upstream release notes and `SHA256SUMS.txt` for the new version.
2. Update `VOXTYPE_VERSION`, asset names, and SHA-256 digests in
   `lib/fedora-setup/voxtype.sh`.
3. Move the old `~/.local/bin/voxtype` aside if the checksum will change.
4. Run `./bin/fedora-setup --dry-run voxtype`, then `./bin/fedora-setup voxtype`.
5. Validate short dictations in Alacritty, Chromium, and a Flatpak text field.
6. Record the new pin in the commit message.

## Disablement and rollback

Stop and detach the daemon without deleting models:

```bash
systemctl --user stop voxtype.service
rm -f ~/.config/systemd/user/niri.service.wants/voxtype.service
systemctl --user daemon-reload
```

Remove the managed binary and linked unit/config:

```bash
sha256sum ~/.local/bin/voxtype   # confirm it is still the pinned artifact
rm ~/.local/bin/voxtype
rm -f ~/.local/bin/voxtype-osd-gtk4
rm -f ~/.config/systemd/user/voxtype.service
rm -f ~/.config/voxtype/config.toml
systemctl --user daemon-reload
```

Remove niri bindings by deleting the Voxtype entries from
`config/niri/config.kdl` (or restoring a backup) and re-running the `config`
phase.

Optionally delete user data:

```bash
rm -rf ~/.local/share/voxtype
rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/voxtype"
```

Fedora package rollback for the typing backend:

```bash
sudo dnf remove wtype
```

Only remove `wtype` if no other tool needs it.

Remove evdev access only if no other managed tool needs the `input` group:

```bash
sudo gpasswd --delete "$USER" input
```

Log out or reboot after removing membership.

## Validation checklist

- [ ] `./bin/fedora-setup --dry-run voxtype` reports every intended mutation
- [ ] `./bin/fedora-setup voxtype` is idempotent on a second run
- [ ] `./bin/fedora-setup status` shows pinned binary, model, linked unit, and active service in a niri session
- [ ] `bash -n` and ShellCheck pass on the touched shell files
- [ ] `niri validate --config config/niri/config.kdl` succeeds
- [ ] Short dictation inserts into Alacritty, Chromium, a native GTK field, and a Flatpak text field
- [ ] The waveform OSD appears while recording and no start/stop notification is shown
- [ ] Network-disconnected dictation still succeeds with the default config
- [ ] `Escape` cancels an in-progress recording while remaining usable in applications when Voxtype is idle
- [ ] Microphone denial and a stopped daemon surface clear failures without locking the session
