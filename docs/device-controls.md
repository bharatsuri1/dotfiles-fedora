# Device recovery

Use `wlctl` for Wi-Fi, `nmtui` for connection-profile editing and fallback,
`bluetui` for Bluetooth, and `wiremix` for audio. Consult their on-screen help
for controls. If an interface fails, the backing services remain accessible:

```bash
nmcli device
bluetoothctl
wpctl status
./bin/fedora-setup status
```

If an installed pinned binary fails verification, compare it with the previous
repository version before moving it aside and rerunning the `device-controls`
phase. Do not overwrite an unrecognized installation.

Restart a backing service only when interruption is acceptable:

```bash
sudo systemctl restart NetworkManager.service
sudo systemctl restart bluetooth.service
systemctl --user restart pipewire.service wireplumber.service
```

NetworkManager restart interrupts networking, including remote access. Audio
restart interrupts playback and capture. Missing Bluetooth hardware does not
require removing the network or audio tools.

Removing an interface does not require deleting saved connections, pairings,
or audio state. Preserve NetworkManager, BlueZ, PipeWire, and WirePlumber.
Keep `nmtui` available as a network recovery path.
