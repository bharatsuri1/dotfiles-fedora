# Zed

Managed portable configuration for the Flathub Zed Flatpak (`dev.zed.Zed`).

## Ownership

| Object | Owner | Path |
| --- | --- | --- |
| Settings | This repository | `~/.var/app/dev.zed.Zed/config/zed/settings.json` |
| Vesper theme | This repository | `~/.var/app/dev.zed.Zed/config/zed/themes/vesper.json` |
| Keymap | This repository | `~/.var/app/dev.zed.Zed/config/zed/keymap.json` |
| Shell alias `zed` | This repository (`config/zsh/aliases.zsh`) | interactive Zsh only |
| Extensions | User; allowlist empty | `~/.var/app/dev.zed.Zed/data/zed/extensions/` |
| DB, logs, cache, threads, prompts, accounts | Runtime / user | never tracked |

niri still launches Zed with `flatpak run dev.zed.Zed` (`Super+Ctrl+Z`). The
managed `zed` alias is the interactive terminal entrypoint and is not required
for the niri bind.

## Portable settings

`config/zed/settings.json` keeps a small set aligned with the rest of the
machine:

- Vim mode with always-on relative line numbers, smartcase find/search, and yank highlight
- Inter UI font and JetBrainsMono Nerd Font buffer font
- Editor ergonomics: soft wrap, sticky scroll, scroll margin, unified diffs, minimap, quit confirm
- Project panel left/dense/closed-by-default; tabs show icons, git status, and errors
- Preview tabs disabled for panel clicks, code navigation, and multibuffers
- Telemetry diagnostics/metrics off
- `session.trust_all_worktrees` enabled deliberately; unsaved buffer restore off
- Theme name `Vesper` (custom file below)

Also managed from UI-tuned preferences (kept portable on purpose):

- `show_edit_predictions: false` and `edit_predictions` (`mode: subtle`, no data collection)
- `agent` defaults (Ollama model, modifier-to-send, tool permissions, sidebar)
- `language_models.opencode` (hide free/zen model lists)

Intentionally **not** managed right now:

- Extensions
- Secrets, API tokens, and account/sync state

## Keybindings

Managed `config/zed/keymap.json` departures from Zed defaults:

| Binding | Context | Action |
| --- | --- | --- |
| `j k` | insert mode | leave insert (`vim::NormalBefore`) |
| `ctrl-w h/j/k/l` | docks (terminal, panels) | move focus across panes/docks |
| `space e` | normal/visual vim + empty pane | focus project panel |
| `space f` | same | file finder |
| `space t` | same | terminal panel |
| `space b` | same | toggle left dock |

Leader-style `space` bindings only apply in vim control contexts (and empty pane), so they do not steal insert-mode space.

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
| `./bin/laptop-setup zed` | Ensures Flatpak presence (or dry-run note) and links settings + theme |
| `./bin/laptop-setup config` | Calls the same `link_zed_config` helpers so relinks stay in sync |
| `./bin/laptop-setup apply` | Runs `zed` after `flatpaks` and still runs full `config` later |

Both paths use `link_config`, so conflicting files are backed up under
`~/.local/state/dotfiles-fedora/backups/`.

## Status

`./bin/laptop-setup status` reports Flatpak install state, managed link state for
settings and theme, the managed alias definition, and the empty allowlist.

## Validation

```bash
python3 -m json.tool config/zed/settings.json >/dev/null
python3 -m json.tool config/zed/themes/vesper.json >/dev/null
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
# restore from ~/.local/state/dotfiles-fedora/backups/<timestamp>/... if needed
# remove the zed alias from config/zsh/aliases.zsh or stop linking aliases
```

Removing the Flatpak is out of band: `flatpak uninstall dev.zed.Zed`.
