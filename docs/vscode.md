# VS Code

Managed portable configuration for the Flathub Visual Studio Code Flatpak
(`com.visualstudio.code`).

## Ownership

| Object | Owner | Path |
| --- | --- | --- |
| Settings | This repository | `~/.var/app/com.visualstudio.code/config/Code/User/settings.json` |
| Keybindings | This repository | `~/.var/app/com.visualstudio.code/config/Code/User/keybindings.json` |
| Shell alias `code` | This repository (`config/zsh/aliases.zsh`) | interactive Zsh only |
| Extensions | This repository (allowlist); installed by user action | `~/.var/app/com.visualstudio.code/data/vscode/extensions/` |
| Accounts, Settings Sync, tokens, workspace storage, histories, logs, caches, state databases, project-specific `.vscode/` | Runtime / user | never tracked |

The managed `code` alias launches the Flatpak from the interactive terminal.
It is not required for any niri or desktop integration bind.

## Portable settings

`config/vscode/settings.json` keeps a small set aligned with the rest of the
machine:

- **Telemetry off** — telemetry level, feedback, SQM, experiments, natural-language settings search, and extension recommendations all disabled.
- **Fonts** — JetBrainsMono Nerd Font for the editor and integrated terminal at size 14, matching the Zed and Alacritty configuration.
- **Editor ergonomics** — relative line numbers, solid cursor (no blink), minimap enabled, no scroll-beyond-last-line, no sticky scroll, trailing whitespace rendering, bracket pair colorization and guides, linked editing, soft word wrap, 2-space indent, ruler at 100.
- **Files** — trim trailing whitespace, insert final newline, trim final newlines, auto-save on focus change, common excludes.
- **Search** — smart case matching.
- **Git** — smart commit, no confirm sync, auto-fetch, inline blame with 400 ms delay (matches the Zed inline-blame setting).
- **Workbench** — no startup editor, preview tabs disabled, 12 px tree indent, Default Dark Modern theme.
- **Window** — native title bar, hidden menu bar.
- **Terminal** — 10 000-line scrollback, copy on selection, GPU acceleration.
- **Updates** — auto-update and auto-check-updates disabled so Flatpak owns the lifecycle.

Intentionally **not** managed:

- Extensions (see allowlist below).
- Secrets, API tokens, account state, and Settings Sync data.
- Workspace storage, global storage, histories, logs, and caches.
- Project-specific `.vscode/` directories.

## Keybindings

`config/vscode/keybindings.json` defines a small, reviewed set with intentional
departures from VS Code defaults.

### Restored standard editing keys (Editor context)

VS Code on Linux uses Emacs-style chord bindings by default (`Ctrl+Shift+C`
for copy, etc.). These overrides restore conventional GUI behavior:

| Binding | Action | Default it replaces |
| --- | --- | --- |
| `Ctrl+C` | Copy | `Ctrl+Shift+C` (Emacs-style) |
| `Ctrl+X` | Cut | `Ctrl+Shift+X` (Emacs-style) |
| `Ctrl+V` | Paste | `Ctrl+Shift+V` (Emacs-style) |
| `Ctrl+A` | Select all | `Ctrl+Shift+A` (Emacs-style) |
| `Ctrl+S` | Save | `Ctrl+K S` (chord) |

### Quick open

| Binding | Action | Default it replaces |
| --- | --- | --- |
| `Ctrl+E` | Quick open | `Ctrl+P` |

### Integrated terminal

| Binding | Action | Default it replaces |
| --- | --- | --- |
| `Ctrl+Shift+T` | New terminal | `Ctrl+Shift+\`` (backtick) |

## Extension allowlist

The allowlist is currently empty. Each future entry must document:

| Field | Description |
| --- | --- |
| Extension ID | Marketplace identifier (`publisher.name`) |
| Purpose | What it provides and why it is managed |
| Publisher | Who maintains it |
| License / source | License and distribution source |
| Trust assessment | Review notes (permissions, data access, reputation) |
| Removal path | How to uninstall it |

Extensions are installed via `flatpak run --command=code com.visualstudio.code
--install-extension <id>`. Installation is idempotent: the module checks
`--list-extensions` first and skips already-installed entries. Unlisted user
extensions are never removed.

## Customization

To override a managed setting without losing the managed baseline, add a
user-specific override in a separate file or use VS Code's workspace settings
(`.vscode/settings.json` in a project), which take precedence over the
symlinked user settings.

To take full control of settings or keybindings again, remove the managed
symlink and restore the backup:

```bash
rm ~/.var/app/com.visualstudio.code/config/Code/User/settings.json
rm ~/.var/app/com.visualstudio.code/config/Code/User/keybindings.json
# Restore from ~/.local/state/dotfiles-fedora/backups/<timestamp>/
```

## Update behavior

Flatpak owns the VS Code application lifecycle. The managed settings disable
VS Code's built-in auto-update and extension auto-update so that Flatpak
remains the single update source. Re-run `laptop-setup vscode` or
`laptop-setup config` to re-link managed configuration after a checkout
update.

## Rollback

Removing the managed links and restoring backups returns control to the user:

```bash
./bin/laptop-setup --dry-run vscode   # preview what would change
```

The shared `link_config` helper backs up any pre-existing user-owned file to a
timestamped directory under `~/.local/state/dotfiles-fedora/backups/` before
replacing it with the managed symlink. It never silently overwrites.