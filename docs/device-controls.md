# Standalone device controls

The `device-controls` phase installs independent terminal interfaces for
network, Bluetooth, and audio recovery. They do not start background user
processes, replace backing services, or rewrite existing connections, pairings,
routes, default devices, or audio policy.

## Ownership

| Area | Interface | Owner | Backing service |
| --- | --- | --- | --- |
| Network | wlctl 0.1.9 | This repository's pinned upstream artifact | `NetworkManager.service` |
| Network fallback | `nmtui` from `NetworkManager-tui` | Fedora/DNF | `NetworkManager.service` |
| Bluetooth | Bluetui 0.8.1 | This repository's pinned upstream artifact | `bluetooth.service` from BlueZ |
| Audio | `wiremix` | Fedora/DNF | PipeWire and WirePlumber user services |

Fedora 44 provides `NetworkManager-tui` and `wiremix` in its official
repositories. Their versions follow normal Fedora updates. wlctl and Bluetui
are not official Fedora packages, so the setup downloads their static Linux
binaries from pinned upstream releases and installs them under `~/.local/bin`
only after SHA-256 verification.

The desktop foundation also installs Fedora's `alsa-sof-firmware` package so
Intel SOF/SoundWire hardware can register its ALSA playback and capture
devices before PipeWire and WirePlumber discover them.

The managed wlctl artifacts are:

| Architecture | Asset | SHA-256 |
| --- | --- | --- |
| x86_64 | `wlctl-x86_64-unknown-linux-musl` | `5b9532a63d87ca7a3790c5f3c6f9a1c727e92321b7e7089c9e034c649210e903` |
| aarch64 | `wlctl-aarch64-unknown-linux-musl` | `33eb22fdc1665200bcdf59b06a28b17ca27c4f6df34a871ced97120f6b315c40` |

wlctl is licensed under GPL-3.0-only. It brings Impala's Ratatui interaction
model to NetworkManager through its system D-Bus API, so it does not require
`iwd` or replace the existing network backend. The selected release binaries
are statically linked. The upstream source, license, and releases are published
at <https://github.com/aashish-thapa/wlctl>.

wlctl is still a 0.1-series project, so Fedora's `nmtui` remains installed as
the conservative recovery path and full connection-profile editor. Impala was
rejected because it requires `iwd` and explicitly conflicts with NetworkManager.
Gazelle was not selected because its Python/Textual runtime is larger and it
does not publish standalone Linux release artifacts. wlctl best matches the
desired modern Bluetui-like experience while preserving the existing backend.

The managed Bluetui artifacts are:

| Architecture | Asset | SHA-256 |
| --- | --- | --- |
| x86_64 | `bluetui-x86_64-linux-musl` | `c6d133930af3ef85d5fb6492c98982958619284d1f583c2c8ecf46992460d60e` |
| aarch64 | `bluetui-aarch64-linux-musl` | `66a5b1dbf5ab5274a05f6926c62bb4bd27601e15a67606c41df625a0a1f1284f` |

Bluetui is licensed under GPL-3.0-only. Its Linux runtime dependency is the
existing BlueZ daemon and its system D-Bus API; the selected release binaries
are statically linked. The upstream source, license, and releases are published
at <https://github.com/pythops/bluetui>.

`bluetuith` was also evaluated. It supports additional features such as OBEX
file transfer and media controls, but upstream describes the project as alpha
and those features expand the runtime and recovery surface beyond this phase.
The Fedora 44 community COPR examined during evaluation also lagged the current
upstream release and had inconsistent version and source fields. Bluetui is the
smaller fit for the required scan, pair, trust, connect, disconnect, and unpair
workflow.

An existing `~/.local/bin/wlctl` or `~/.local/bin/bluetui` with a different
checksum is never overwritten. Move it aside explicitly before running the
phase if this repository should take ownership.

## Install and launch

Preview or apply only this phase:

```bash
./bin/fedora-setup --dry-run device-controls
./bin/fedora-setup device-controls
```

Launch each interface directly from a terminal:

```bash
wlctl
nmtui
bluetui
wiremix
```

The managed Zsh configuration also provides short aliases:

| Alias | Command |
| --- | --- |
| `wifi` | `wlctl` |
| `bt` | `bluetui` |
| `audio` | `wiremix` |

Use wlctl to scan, connect, disconnect, forget, and troubleshoot networks with
an Impala-style interface; `wlctl doctor` checks the network stack when a
connection fails. Use `nmtui` as the fallback and for detailed NetworkManager
profile editing. Bluetui uses `s` to toggle scanning, Enter or Space to pair or
connect, `t` to trust or untrust, and `u` to unpair. Wiremix exposes PipeWire
devices and streams for volume, mute, default-device, and routing changes; use
its on-screen help for the current key bindings.

Bluetooth is optional. Missing Bluetooth hardware or an inactive Bluetooth
service does not affect installation or the network and audio tools. The
backing services remain authoritative and can still be controlled with
`nmcli`, `bluetoothctl`, `wpctl`, and `systemctl` if a TUI is unavailable.

## Validation and recovery

Inspect package, artifact, and service state without displaying network names,
device identifiers, or audio application metadata:

```bash
./bin/fedora-setup status
```

Live validation on Fedora should cover:

1. Activate and deactivate an existing Wi-Fi profile, then connect to a new
   network with wlctl. Confirm `nmtui` can still inspect and edit the resulting
   NetworkManager profile.
2. Scan, pair, trust, connect, disconnect, and unpair a test Bluetooth device
   with `bluetui`.
3. Change volume, mute playback and capture, select a default device, and move
   a stream with `wiremix`.
4. Restart the relevant backing service and confirm its tool reconnects:

   ```bash
   sudo systemctl restart NetworkManager.service
   sudo systemctl restart bluetooth.service
   systemctl --user restart pipewire.service wireplumber.service
   ```

Restarting NetworkManager interrupts networking, and restarting the audio
services briefly interrupts active audio. Run those checks only when the
temporary interruption is acceptable.

## Updates and rollback

DNF updates `NetworkManager-tui` and `wiremix`. Updating wlctl or Bluetui is an
explicit repository change: review the new upstream release, replace its
version and both architecture hashes in
`lib/fedora-setup/device-controls.sh`, run the validation above, and record the
result in the tracking issue. Before running the updated phase, verify the
installed binary against the previously managed hash and move it aside; the
installer intentionally refuses to overwrite a binary that does not match its
new pin. The pinned binaries do not self-update.

To roll back the interfaces without deleting service state:

```bash
sudo dnf remove NetworkManager-tui wiremix
sha256sum ~/.local/bin/wlctl
sha256sum ~/.local/bin/bluetui
rm ~/.local/bin/wlctl
rm ~/.local/bin/bluetui
```

Compare each printed hash with its managed hash above before removing the
binary. Do not remove NetworkManager, BlueZ, PipeWire, or WirePlumber, and do
not delete their saved state. The managed Zsh aliases can remain harmlessly or
be removed from `config/zsh/aliases.zsh`; no device-specific configuration is
installed by this phase.

Issue #15 may later add Quickshell buttons that launch these programs or use
the same backing services. These terminal interfaces remain independently
usable and are not replaced by that future UI.
