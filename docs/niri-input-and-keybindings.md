# Niri input and keybindings

The managed niri configuration uses responsive keyboard repetition and a
laptop-oriented libinput profile:

- keyboard repeat starts after 200 ms and runs at 35 repeats per second;
- touchpad tap-to-click, natural scrolling, clickfinger, and
  disable-while-typing are enabled;
- touchpad acceleration is `0.2` with libinput's default adaptive profile; and
- touchpad scrolling is scaled to `0.3`.

Navigation, window movement, resizing, volume, and brightness remain
repeatable. Launchers, toggles, media transport, screenshots, lock, quit, and
display-power actions use `repeat=false` so holding a key cannot trigger them
repeatedly.

## Application and utility bindings

In a normal niri session, `Mod` is the Super key.

| Binding | Action |
| --- | --- |
| `Super+T` | Open Alacritty |
| `Super+Ctrl+T` | Open or attach to the default Herdr session in Alacritty |
| `Super+Space` | Open the recovery-capable Fuzzel launcher |
| `Super+B` | Open Chromium |
| `Super+Ctrl+C` | Open ChatGPT in Chromium app mode |
| `Super+Ctrl+Y` | Open YouTube in Chromium app mode |
| `Super+Ctrl+G` | Open GitHub in Chromium app mode |
| `Super+E` | Open Files |
| `Super+Ctrl+Z` | Open Zed |
| `Super+Ctrl+V` | Open Visual Studio Code |
| `Super+Ctrl+S` | Open LocalSend |
| `Super+Ctrl+,` | Dismiss all Mako notifications |

The Herdr binding always opens a new terminal client. Herdr remains responsible
for the persistent default session, worktrees, agent state, and restoration.
Chromium app-mode bindings use the normal Chromium profile and authentication
state; the repository does not store browser credentials.

## Validation and customization

After editing `config/niri/config.kdl`, validate it before reloading:

```bash
niri validate -c config/niri/config.kdl
./bin/laptop-setup --dry-run config
```

Niri normally reloads its active configuration after a valid change. For a
temporary worktree test on niri 26.04 or newer, load an explicit file with:

```bash
niri msg action load-config-file --path /absolute/path/to/config/niri/config.kdl
```

Test repeat behavior in ordinary typing, terminal navigation, and deletion.
Test the touchpad in a browser, terminal, file view, and niri overview, and
confirm that typing does not cause pointer movement. Also verify tap, physical
click, drag, and an external mouse before treating a new touchpad profile as
fully validated.

If input becomes difficult to use, switch to a TTY, restore the previous values
in the managed KDL, run `niri validate`, and restart the graphical session.
Keyboard repeat and touchpad settings apply only to niri and do not change TTY
input. Removing the explicit repeat, acceleration, or scroll settings restores
niri/libinput defaults.
