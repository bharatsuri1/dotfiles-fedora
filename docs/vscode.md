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

### vscodevim.vim

| Field | Value |
| --- | --- |
| Extension ID | `vscodevim.vim` |
| Purpose | Vim modal editing in VS Code, consistent with the managed Zed (vim mode) and Neovim configurations |
| Publisher | VSCodeVim (`vscodevim`) |
| License / source | MIT, distributed via the VS Code Marketplace |
| Trust assessment | Open source, widely adopted, no network or data-collection permissions beyond VS Code's own extension host |
| Removal path | `flatpak run --command=code com.visualstudio.code --uninstall-extension vscodevim.vim` |

### ms-vscode-remote.remote-ssh

| Field | Value |
| --- | --- |
| Extension ID | `ms-vscode-remote.remote-ssh` |
| Purpose | Edit files on remote machines over SSH from within VS Code |
| Publisher | Microsoft (`ms-vscode-remote`) |
| License / source | MIT, distributed via the VS Code Marketplace |
| Trust assessment | First-party Microsoft extension; no telemetry beyond VS Code's own reporting; SSH keys and host credentials stay on the host machine |
| Removal path | `flatpak run --command=code com.visualstudio.code --uninstall-extension ms-vscode-remote.remote-ssh` |

### ms-vscode-remote.remote-ssh-edit

| Field | Value |
| --- | --- |
| Extension ID | `ms-vscode-remote.remote-ssh-edit` |
| Purpose | Lightweight SSH file editing without a full remote server install (companion to remote-ssh) |
| Publisher | Microsoft (`ms-vscode-remote`) |
| License / source | MIT, distributed via the VS Code Marketplace |
| Trust assessment | First-party Microsoft extension; same trust profile as remote-ssh |
| Removal path | `flatpak run --command=code com.visualstudio.code --uninstall-extension ms-vscode-remote.remote-ssh-edit` |

### GitHub.vscode-pull-request-github

| Field | Value |
| --- | --- |
| Extension ID | `GitHub.vscode-pull-request-github` |
| Purpose | Review and manage GitHub pull requests and issues from within VS Code |
| Publisher | GitHub (`GitHub`) |
| License / source | MIT, distributed via the VS Code Marketplace |
| Trust assessment | First-party GitHub extension; requires GitHub authentication through VS Code's built-in auth provider; no credentials stored by the extension itself |
| Removal path | `flatpak run --command=code com.visualstudio.code --uninstall-extension GitHub.vscode-pull-request-github` |

### ms-vscode.remote-explorer

| Field | Value |
| --- | --- |
| Extension ID | `ms-vscode.remote-explorer` |
| Purpose | Explorer view for remote SSH and container connections |
| Publisher | Microsoft (`ms-vscode`) |
| License / source | MIT, distributed via the VS Code Marketplace |
| Trust assessment | First-party Microsoft extension; UI-only companion to the remote extensions |
| Removal path | `flatpak run --command=code com.visualstudio.code --uninstall-extension ms-vscode.remote-explorer` |

### openai.chatgpt

| Field | Value |
| --- | --- |
| Extension ID | `openai.chatgpt` |
| Purpose | ChatGPT integration for in-editor AI assistance |
| Publisher | OpenAI (`openai`) |
| License / source | Proprietary, distributed via the VS Code Marketplace |
| Trust assessment | First-party OpenAI extension; sends code context to OpenAI's API per user request; requires user-provided API key or sign-in; no background data collection |
| Removal path | `flatpak run --command=code com.visualstudio.code --uninstall-extension openai.chatgpt` |

### raunofreiberg.vesper

| Field | Value |
| --- | --- |
| Extension ID | `raunofreiberg.vesper` |
| Purpose | Vesper color theme for VS Code, consistent with the managed Zed and SDDM Vesper themes |
| Publisher | Rauno Freiberg (`raunofreiberg`) |
| License / source | MIT, distributed via the VS Code Marketplace |
| Trust assessment | Open-source theme extension; no permissions, no network access, no data collection |
| Removal path | `flatpak run --command=code com.visualstudio.code --uninstall-extension raunofreiberg.vesper` |

### ms-azuretools.vscode-docker

| Field | Value |
| --- | --- |
| Extension ID | `ms-azuretools.vscode-docker` |
| Purpose | Build, manage, and inspect Docker images and containers from within VS Code |
| Publisher | Microsoft (`ms-azuretools`) |
| License / source | MIT, distributed via the VS Code Marketplace |
| Trust assessment | First-party Microsoft extension; interacts with the local Docker socket; no external network access beyond Docker's own |
| Removal path | `flatpak run --command=code com.visualstudio.code --uninstall-extension ms-azuretools.vscode-docker` |

### ms-vscode-remote.remote-containers

| Field | Value |
| --- | --- |
| Extension ID | `ms-vscode-remote.remote-containers` |
| Purpose | Open any project inside a Dev Container for reproducible development environments |
| Publisher | Microsoft (`ms-vscode-remote`) |
| License / source | MIT, distributed via the VS Code Marketplace |
| Trust assessment | First-party Microsoft extension; requires Docker; container definitions are user-controlled via devcontainer.json |
| Removal path | `flatpak run --command=code com.visualstudio.code --uninstall-extension ms-vscode-remote.remote-containers` |

### ms-azuretools.vscode-containers

| Field | Value |
| --- | --- |
| Extension ID | `ms-azuretools.vscode-containers` |
| Purpose | Container management view (companion to vscode-docker) for browsing and inspecting running containers |
| Publisher | Microsoft (`ms-azuretools`) |
| License / source | MIT, distributed via the VS Code Marketplace |
| Trust assessment | First-party Microsoft extension; same trust profile as vscode-docker |
| Removal path | `flatpak run --command=code com.visualstudio.code --uninstall-extension ms-azuretools.vscode-containers` |

### GitHub.vscode-github-actions

| Field | Value |
| --- | --- |
| Extension ID | `GitHub.vscode-github-actions` |
| Purpose | GitHub Actions workflow validation, autocomplete, and run status in VS Code |
| Publisher | GitHub (`GitHub`) |
| License / source | MIT, distributed via the VS Code Marketplace |
| Trust assessment | First-party GitHub extension; reads workflow YAML and queries GitHub API for run status; requires GitHub authentication through VS Code's built-in auth provider |
| Removal path | `flatpak run --command=code com.visualstudio.code --uninstall-extension GitHub.vscode-github-actions` |

### sst-dev.opencode

| Field | Value |
| --- | --- |
| Extension ID | `sst-dev.opencode` |
| Purpose | OpenCode AI assistant integration in VS Code, consistent with the managed OpenCode Flatpak and terminal workflow |
| Publisher | SST (`sst-dev`) |
| License / source | MIT, distributed via the VS Code Marketplace |
| Trust assessment | Open-source extension; connects to user-configured OpenCode or Ollama endpoints; no credentials stored by the extension beyond local configuration |
| Removal path | `flatpak run --command=code com.visualstudio.code --uninstall-extension sst-dev.opencode` |

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