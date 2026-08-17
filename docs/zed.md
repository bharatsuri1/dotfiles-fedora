# Zed

Managed portable configuration for the Flathub Zed Flatpak (`dev.zed.Zed`).

## Ownership

| Object | Owner | Path |
| --- | --- | --- |
| Settings | This repository | `~/.var/app/dev.zed.Zed/config/zed/settings.json` |
| Vesper theme | This repository | `~/.var/app/dev.zed.Zed/config/zed/themes/vesper.json` |
| Keymap | This repository | `~/.var/app/dev.zed.Zed/config/zed/keymap.json` |
| Shell alias `zed` | This repository (`config/zsh/aliases.zsh`) | interactive Zsh only |
| Flatpak override | This repository (`lib/laptop-setup/zed.sh`) | `flatpak override --user` |
| Extensions | User; allowlist empty | `~/.var/app/dev.zed.Zed/data/zed/extensions/` |
| DB, logs, cache, threads, prompts, accounts | Runtime / user | never tracked |

niri still launches Zed with `flatpak run dev.zed.Zed` (`Super+Ctrl+Z`). The
managed `zed` alias is the interactive terminal entrypoint and is not required
for the niri bind.

## Portable settings

`config/zed/settings.json` keeps a small set aligned with the rest of the
machine:

- Vim mode with always-on relative line numbers, smartcase find/search, yank highlight, and `gdefault` (substitute replaces all matches in a line by default)
- Inter UI font and JetBrainsMono Nerd Font buffer font
- Editor ergonomics: soft wrap, sticky scroll, scroll margin, no scroll-beyond-last-line, hidden scrollbar, unified diffs, minimap, quit confirm
- Project panel left/dense/closed-by-default; tabs show icons, git status, and errors
- Preview tabs disabled for panel clicks, code navigation, and multibuffers
- Telemetry diagnostics/metrics off
- `session.trust_all_worktrees` enabled deliberately; unsaved buffer restore off
- Theme name `Vesper` (custom file below)
- Command aliases for common vim typos (`W` → `w`, `Q` → `q`, etc.)

Also managed from UI-tuned preferences (kept portable on purpose):

- `show_edit_predictions: false` and `edit_predictions` (`mode: subtle`, no data collection)
- `agent` defaults (Ollama model, modifier-to-send, tool permissions, sidebar)
- `language_models.opencode` (hide free/zen model lists)

Intentionally **not** managed right now:

- Extensions
- Secrets, API tokens, and account/sync state

## Keybindings

Managed `config/zed/keymap.json` builds a keyboard-driven workflow on top of
Zed's vim mode. Space is the leader key in normal and visual mode.

### Insert mode

| Binding | Action |
| --- | --- |
| `j k` | leave insert (`vim::NormalBefore`) |

### Restored editing keys (Editor context, overrides vim defaults)

| Binding | Action | Vim default it replaces |
| --- | --- | --- |
| `ctrl-v` | paste | visual block (`vim::ToggleVisualBlock`) |
| `ctrl-c` | copy | return to normal |
| `ctrl-x` | cut | decrement |
| `ctrl-a` | select all | increment |
| `ctrl-s` | save | — |
| `ctrl-f` | buffer search | page down |
| `ctrl-z` | undo | suspend |
| `ctrl-shift-z` | redo | — |

### Scrolling

| Binding | Action |
| --- | --- |
| `ctrl-d` / `ctrl-u` | half-page scroll + center cursor (`zz`) |
| `ctrl-f` | buffer search (page down via `ctrl-d`/`ctrl-b`) |

Vim defaults preserved: `ctrl-b` (page up), `ctrl-e`/`ctrl-y` (line scroll),
`zz`/`zt`/`zb`/`z.` (centering), `H`/`M`/`L` (window jump).

### Pane & dock navigation

| Binding | Context | Action |
| --- | --- | --- |
| `ctrl-w h/j/k/l` | docks | move focus across panes/docks |

### Space leader (normal & visual vim, empty pane)

#### Panels

| Binding | Action |
| --- | --- |
| `space e` | project panel (toggle) |
| `space f` | file finder |
| `space t` | terminal panel |
| `space g` | git panel (toggle) |
| `space a` | agent panel |
| `space o` | outline |
| `space d` | diagnostics |

#### Docks & zoom

| Binding | Action |
| --- | --- |
| `space H` | toggle left dock |
| `space L` | toggle right dock |
| `space A` | toggle all docks |
| `space z` | toggle editor zoom |

#### File & buffer

| Binding | Action |
| --- | --- |
| `space s` | save |
| `space n` | new file |
| `space w` | close buffer |
| `space q` | close pane |
| `space Q` | close all items |
| `space b` | tab switcher |
| `space T` | reopen closed tab |
| `space p` | reveal in project panel |
| `tab` / `shift-tab` | next / previous buffer |
| `] b` / `[ b` | next / previous buffer |

#### Search

| Binding | Action |
| --- | --- |
| `space *` | project search |
| `ctrl-f` | buffer search |

Vim defaults preserved: `/` `?` `*` `#` `n` `N` (buffer search),
`:s/foo/bar/` (substitute with `gdefault`), `g /` (project search).

#### Code

| Binding | Action |
| --- | --- |
| `space r` | rename symbol |
| `space c` | toggle comments |
| `space x` | code actions |
| `space m` | format (model selector in agent thread) |
| `space k` | hover |
| `space l` | restart language server |

Vim defaults preserved: `gd`/`gD`/`gy`/`gI`/`gA` (go to def/decl/type/impl/refs),
`g]`/`g[`/`]d`/`[d` (diagnostics), `g.` (code actions), `gh`/`K` (hover),
`cd` (rename), `gs`/`gS` (symbols).

#### Editing

| Binding | Action |
| --- | --- |
| `space J` | move line down |
| `space K` | move line up |
| `space D` | duplicate line down |

#### Splits

| Binding | Action |
| --- | --- |
| `space v` | vertical split (right) |
| `space -` | horizontal split (down) |

Vim defaults preserved: `ctrl-w v`/`s`/`c`/`o`/`=`/`w` (splits, close, equal, cycle).

#### Agent & threads

| Binding | Action |
| --- | --- |
| `space a` | toggle agent panel |
| `space N` | new agent thread |
| `space B` | thread switcher |
| `space m` | model selector (in agent thread editor) |

#### Other

| Binding | Action |
| --- | --- |
| `space ;` | command palette |
| `space R` | recent projects |
| `space M` | minimap toggle |
| `space G` | inline git blame |

### Terminal

| Binding | Action |
| --- | --- |
| `ctrl-shift-t` | new terminal |
| `ctrl-shift-v` | toggle vi mode |
| `ctrl-v` | paste |

### Text objects (operator-pending: after `i`, `a`, or `cs`)

| Binding | Action |
| --- | --- |
| `q` | any quotes (`ciq`, `daq`, `cs"q'`) |
| `b` | any brackets (`cib`, `dab`, `cs(b)`) |

### Visual mode

| Binding | Action |
| --- | --- |
| `S` | add surrounds (`S)` wraps selection in parens) |

### Design notes

- Space leader bindings use `VimControl && !menu` context (not `Editor`) to
  avoid the space-input-delay issue when `space` is used as a motion prefix.
- A subset of space bindings is duplicated in `EmptyPane || SharedScreen` so
  they work when no editor is focused.
- `tab`/`shift-tab` override vim line indent (`vim::Tab`); use `>` for indent.
- `ctrl-d`/`ctrl-u` use `SendKeystrokes` to chain the default scroll with `zz`
  (center cursor). Completion menu scrolling is unaffected (different context).
- `space m` is context-aware: format in regular editors, model selector in
  agent thread editors (`AcpThread > Editor && VimControl && !menu`).
- Panel toggles use `Toggle` (open/close), not `ToggleFocus` (focus only).
- AnyQuotes/AnyBrackets text objects implement traditional Vim behavior
  (innermost delimiters, line fallback). MiniQuotes/MiniBrackets (`Q` / `B`)
  are available but intentionally not bound.
- Visual `S` overrides the default visual substitute to enable surround
  wrapping — use `s` in normal mode for substitute as usual.
- Terminal `ctrl-shift-v` is repurposed from paste to vi mode toggle;
  `ctrl-v` handles paste instead.

## Flatpak clipboard workaround

The Flatpak Wayland proxy does not properly forward the Wayland clipboard
(`wl_data_device`) to niri. As a result, vim yank (`y`) silently fails to
write to the system clipboard — `use_system_clipboard: "always"` is set but the
compositor never receives the clipboard contents.

This is a known issue across multiple Flatpak apps on niri (and other
non-wlroots compositors) — the necessary Wayland protocols are not exposed
through the Flatpak proxy socket.

### Managed fix

`install_zed` applies a per-user Flatpak override that forces X11 mode through
XWayland, where the X11 clipboard works reliably:

```bash
flatpak override --user --socket=x11 --nosocket=wayland dev.zed.Zed
```

This makes Zed run as an X11 app through `xwayland-satellite` instead of a
native Wayland app. The trade-off is the loss of native Wayland features
(fractional scaling, etc.), but clipboard is a daily-critical feature.

### Rollback

To revert to native Wayland (clipboard will stop working):

```bash
flatpak override --user --reset dev.zed.Zed
```

### When to revisit

Remove this workaround when either:
- Flatpak properly forwards `wl_data_device` through the Wayland proxy, or
- Zed adds a fallback clipboard mechanism (e.g., `wl-copy` or portal-based)
  that works inside the Flatpak sandbox on niri.

Relevant upstream issues:
- [zed#51636](https://github.com/zed-industries/zed/issues/51636) — Wayland clipboard serial
- [zed#62002](https://github.com/zed-industries/zed/issues/62002) — niri-specific clipboard failure
- [bitwarden#21288](https://github.com/bitwarden/clients/issues/21288) — Flatpak + niri clipboard (cross-app)

## Vesper theme

There was no suitable marketplace theme. Setup ships a custom theme family at
`config/zed/themes/vesper.json`.

- **Structure** started from the upstream Zed **Ayu Dark** theme dump
  (`assets/themes/ayu/ayu.json` in the Zed repository), then recolored.
- **Palette** matches `config/alacritty/themes/vesper.toml` and
  `config/quickshell/theme/Theme.qml` (`#101010` background, `#ffffff`
  foreground, `#a0a0a0` dim, `#ffc799` accent, Vesper ANSI colors).

Zed loads user themes from the Flatpak config `themes/` directory. The managed
settings select `"theme": "Vesper"`.

Refine colors after a visual pass in the app; unknown style keys are generally
ignored across Zed upgrades.

## CLI / alias

```zsh
alias zed='flatpak run dev.zed.Zed'
```

After `laptop-setup config` (or `shell` + new Zsh), `zed --help` and
`zed path/to/file` work in interactive Zsh. Non-interactive scripts should call
`flatpak run dev.zed.Zed` explicitly (as niri does).

No `~/.local/bin/zed` wrapper is installed.

## Extensions

The allowlist in `lib/laptop-setup/zed.sh` is empty. Future entries should record
purpose, publisher, license/source, trust notes, and removal steps here before
automated install is wired. Setup must never remove user-installed extensions
that are not on the allowlist.

## Setup phases

| Command | Behavior |
| --- | --- |
| `./bin/laptop-setup zed` | Ensures Flatpak presence (or dry-run note), links settings + theme, and applies flatpak override |
| `./bin/laptop-setup config` | Calls the same `link_zed_config` helpers so relinks stay in sync |
| `./bin/laptop-setup apply` | Runs `zed` after `flatpaks` and still runs full `config` later |

Both paths use `link_config`, so conflicting files are backed up under
`~/.local/state/dotfiles-fedora/backups/`.

## Status

`./bin/laptop-setup status` reports Flatpak install state, managed link state for
settings and theme, the managed alias definition, the empty allowlist, and the
flatpak override state.

## Validation

```bash
python3 -m json.tool config/zed/settings.json >/dev/null
python3 -m json.tool config/zed/themes/vesper.json >/dev/null
python3 -m json.tool config/zed/keymap.json >/dev/null
bash -n bin/laptop-setup lib/laptop-setup/zed.sh
./bin/laptop-setup --dry-run zed
./bin/laptop-setup status
# interactive zsh:
zed --help
```

## Rollback

```bash
rm -f ~/.var/app/dev.zed.Zed/config/zed/settings.json
rm -f ~/.var/app/dev.zed.Zed/config/zed/themes/vesper.json
rm -f ~/.var/app/dev.zed.Zed/config/zed/keymap.json
flatpak override --user --reset dev.zed.Zed
# restore from ~/.local/state/dotfiles-fedora/backups/<timestamp>/... if needed
# remove the zed alias from config/zsh/aliases.zsh or stop linking aliases
```

Removing the Flatpak is out of band: `flatpak uninstall dev.zed.Zed`.
