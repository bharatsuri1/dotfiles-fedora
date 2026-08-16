# Niri keybindings

Complete reference for the bindings defined in `config/niri/config.kdl`.
For input device settings (keyboard repeat, touchpad) and the
validation/customization procedure, see
[niri-input-and-keybindings.md](niri-input-and-keybindings.md); this document
is the authoritative binding list.

## Conventions

- `Mod` is the **Super** key in a normal niri session. Bindings below are
  written with `Super`.
- Bindings marked **non-repeat** use `repeat=false`, so holding the key fires
  the action once. Everything else (focus, movement, resize, volume, brightness)
  repeats at the configured 200 ms delay / 35 cps rate.
- Bindings marked **locked** use `allow-when-locked=true` and still fire from
  the lock screen.
- Bindings marked **no-inhibit** use `allow-inhibiting=false`, so focused apps
  cannot grab them (used for lock and shortcut-inhibit).
- Managed screenshots save to the XDG Pictures `Screenshots/` directory as
  `screenshot-YYYY-MM-DD_HH-MM-SS-NNNNNNNNN.png` and are copied to the
  clipboard. Set `DOTFILES_SCREENSHOT_DIR` to override the directory.

## Application & launcher bindings

All non-repeat. Chromium `--app=` bindings reuse the normal Chromium profile and
authentication state; the repository stores no browser credentials.

| Binding | Action | Command |
| --- | --- | --- |
| `Super+T` | Open Alacritty | `alacritty` |
| `Super+Ctrl+T` | Open a Herdr client in Alacritty | `alacritty … -e herdr` |
| `Super+Space` | Open the Fuzzel launcher | `fuzzel` |
| `Super+B` | Open Chromium | `chromium-browser` |
| `Super+Ctrl+C` | Open ChatGPT (Chromium app mode) | `chromium-browser --app=https://chatgpt.com/` |
| `Super+Ctrl+Y` | Open YouTube (Chromium app mode) | `chromium-browser --app=https://youtube.com/` |
| `Super+Ctrl+G` | Open GitHub (Chromium app mode) | `chromium-browser --app=https://github.com/` |
| `Super+E` | Open Files | `nautilus --new-window` |
| `Super+Ctrl+Z` | Open Zed | `flatpak run dev.zed.Zed` |
| `Super+Ctrl+V` | Open Visual Studio Code | `flatpak run com.visualstudio.code` |
| `Super+Ctrl+S` | Open LocalSend | `flatpak run org.localsend.localsend_app` |
| `Super+Ctrl+,` | Dismiss all Mako notifications | `makoctl dismiss --all` |

## Window focus & navigation

Repeatable. Arrow keys and `HJKL` are aliases (`H`/`L` cross columns or monitors,
`J`/`K` move between windows in a column).

| Binding | Action |
| --- | --- |
| `Super+Left` / `Super+H` | Focus column or monitor to the left |
| `Super+Right` / `Super+L` | Focus column or monitor to the right |
| `Super+Down` / `Super+J` | Focus window down |
| `Super+Up` / `Super+K` | Focus window up |
| `Super+Page Down` | Focus workspace down |
| `Super+Page Up` | Focus workspace up |
| `Super+1` … `Super+9` | Focus workspace 1–9 |

## Move windows & columns / workspaces

Repeatable. Movement follows the same arrow/HJKL scheme as focus.

| Binding | Action |
| --- | --- |
| `Super+Ctrl+Left` / `Super+Ctrl+H` | Move column left or to the left monitor |
| `Super+Ctrl+Right` / `Super+Ctrl+L` | Move column right or to the right monitor |
| `Super+Ctrl+Down` / `Super+Ctrl+J` | Move window down |
| `Super+Ctrl+Up` / `Super+Ctrl+K` | Move window up |
| `Super+Ctrl+Page Down` | Send column to workspace down |
| `Super+Ctrl+Page Up` | Send column to workspace up |
| `Super+Ctrl+1` … `Super+Ctrl+9` | Send column to workspace 1–9 |

## Resize, column layout & window state

All non-repeat unless noted. Width/height adjustments are repeatable.

| Binding | Repeat | Action |
| --- | --- | --- |
| `Super+-` | yes | Shrink column width by 10% |
| `Super+=` | yes | Grow column width by 10% |
| `Super+Shift+-` | yes | Shrink window height by 10% |
| `Super+Shift+=` | yes | Grow window height by 10% |
| `Super+R` | no | Cycle preset column width |
| `Super+Shift+R` | no | Cycle preset column width (reverse) |
| `Super+Ctrl+R` | no | Reset window height |
| `Super+Ctrl+Shift+R` | no | Cycle preset window height |
| `Super+[` | no | Consume or expel window to/from the left |
| `Super+]` | no | Consume or expel window to/from the right |
| `Super+C` | no | Center the column |
| `Super+F` | no | Maximize the column |
| `Super+Shift+F` | no | Fullscreen the window |
| `Super+M` | no | Maximize window to screen edges |
| `Super+V` | no | Toggle floating for the window |
| `Super+Shift+V` | no | Switch focus between floating and tiling |
| `Super+W` | no | Toggle tabbed display in the column |

## Session & system control

All non-repeat.

| Binding | Attribute | Action |
| --- | --- | --- |
| `Super+?` (`Super+Shift+/`) | — | Show the hotkey overlay |
| `Super+O` | — | Toggle the overview |
| `Super+Q` | — | Close the focused window |
| `Super+Shift+L` | no-inhibit | Lock the screen (`lock-screen`) |
| `Super+Escape` | no-inhibit | Toggle keyboard-shortcut inhibition |
| `Super+Shift+E` | — | Quit niri |
| `Ctrl+Alt+Delete` | — | Quit niri |
| `Super+Shift+P` | — | Power off monitors |

## Screenshots

All non-repeat.

| Binding | Action |
| --- | --- |
| `Print` | Select a region, then save and copy it |
| `Ctrl+Print` | Capture the focused screen, then save and copy it |
| `Alt+Print` | Capture the focused window, then save and copy it |
| `Super+Shift+S` | Select a region and open it directly in Tensaku |
| `Shift+Print` | Open niri's native screenshot UI |

The managed capture commands show a thumbnail notification with an **Edit**
action. See [screenshots.md](screenshots.md) for the full workflow and recovery
instructions.

## Media & hardware keys

All **locked** (work from the lock screen) via dedicated media keys. Volume and
brightness repeat; mute and transport are non-repeat.

| Key | Repeat | Action |
| --- | --- | --- |
| `Volume Up` | yes | Raise sink volume by 10% (capped at 100%) |
| `Volume Down` | yes | Lower sink volume by 10% |
| `Volume Mute` | no | Toggle sink mute |
| `Mic Mute` | no | Toggle microphone mute |
| `Play` / `Pause` | no | Play or pause media (`playerctl play-pause`) |
| `Stop` | no | Stop media (`playerctl stop`) |
| `Previous` | no | Previous track (`playerctl previous`) |
| `Next` | no | Next track (`playerctl next`) |
| `Brightness Up` | yes | Raise backlight by 10% |
| `Brightness Down` | yes | Lower backlight by 10% |
