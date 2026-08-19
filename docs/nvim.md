# Neovim

Managed portable configuration for Neovim using [LazyVim](https://www.lazyvim.org/).
Neovim itself is installed by the `packages` phase (DNF); this phase only links
the managed LazyVim configuration.

## Ownership

| Object | Owner | Path |
| --- | --- | --- |
| LazyVim config | This repository | `~/.config/nvim` (symlink to `config/nvim`) |
| Plugin lockfile | This repository | `config/nvim/lazy-lock.json` |
| lazy.nvim + plugins | Runtime (bootstrapped) | `~/.local/share/nvim/lazy/` |
| Plugin state, shada, logs | Runtime | `~/.local/state/nvim/` |
| Cache | Runtime | `~/.cache/nvim/` |
| Shell alias `vim` | This repository (`config/zsh/aliases.zsh`) | interactive Zsh only |

`~/.config/nvim` is a symlink into this checkout, so the managed config is
read-only from Neovim's perspective. lazy.nvim clones itself and all plugins
into `~/.local/share/nvim/lazy/` at first launch; that runtime state is never
tracked.

## Installation model

The config vendors the [LazyVim starter](https://github.com/LazyVim/starter)
(Apache-2.0) into `config/nvim/`:

- `init.lua` bootstraps `config.lazy`
- `lua/config/lazy.lua` clones lazy.nvim (stable branch) on first run, then
  imports LazyVim and the local `plugins/` directory
- `lua/config/{autocmds,keymaps,options}.lua` hold local overrides
- `lua/plugins/*.lua` hold plugin specs and LazyVim overrides
- `.neoconf.json` and `stylua.toml` configure lua_ls and Stylua for the config

Unlike the pinned zsh plugins, LazyVim plugin versions are **not** pinned via
`version =`: `lazy.lua` keeps LazyVim's recommended `version = false` (latest
git commit). LazyVim explicitly warns that semver releases for many plugins are
stale and can break the install. The `checker` is enabled so `:Lazy` surfaces
updates without notifications.

`lazy-lock.json` is still committed: lazy.nvim records the exact commit each
plugin was synced to, and committing the lockfile makes installs reproducible
(`:Lazy restore` / `:Lazy sync` install the locked commits). `lazyvim.json`
(extras, news read marker, install version) is local state and is git-ignored.

## Theme

`lua/plugins/colorscheme.lua` installs
[`datsfilipe/vesper.nvim`](https://github.com/datsfilipe/vesper.nvim), a port of
the VS Code [Vesper](https://github.com/raunofreiberg/vesper) theme, and sets
`opts.colorscheme = "vesper"` on LazyVim. This is the same Vesper identity used
by Zed (`config/zed/themes/vesper.json`), Alacritty
(`config/alacritty/themes/vesper.toml`), and Quickshell
(`config/quickshell/theme/Theme.qml`).

`lazy.lua` keeps `install.colorscheme = { "tokyonight", "habamax" }` as the
fallback used during the very first plugin install, before `vesper.nvim` has
been cloned.

## Options

`lua/config/options.lua` mirrors the managed Zed settings
(`config/zed/settings.json`) on top of LazyVim's defaults:

- `gdefault` — substitute replaces all matches in a line by default (Zed `gdefault`)
- `scrolloff = 10` — 10-line scroll margin (Zed `vertical_scroll_margin`)
- `guifont = "JetBrainsMono Nerd Font:h14"` — GUI clients only; terminal Neovim
  inherits the font from Alacritty, which already uses JetBrainsMono Nerd Font

LazyVim already provides the rest of the Zed parity by default: relative line
numbers, smartcase search, yank highlight, and soft wrap.

## Keymaps

LazyVim's default keymaps (space leader, which-key discoverable) already cover
most of the managed Zed keymap (`config/zed/keymap.json`).
`lua/config/keymaps.lua` adds the Zed behaviors LazyVim does not provide by
default:

| Binding | Mode | Action | Zed equivalent |
| --- | --- | --- | --- |
| `j k` | insert | leave insert mode | `vim::NormalBefore` |
| `<C-d>` | normal | half-page down + center | `ctrl-d z z` |
| `<C-u>` | normal | half-page up + center | `ctrl-u z z` |
| `<leader>m` | normal | format | `space m` |
| `<leader>k` | normal | hover | `space k` |
| `<leader>v` | normal | split right | `space v` |
| `<leader>z` | normal | toggle zoom | `space z` |

The four single-letter leader bindings use keys LazyVim leaves free; LazyVim's
two-letter equivalents (`<leader>cf`, `K`, `<leader>|`, `<leader>wm`) remain
available alongside them.

The remaining Zed leader bindings map onto LazyVim defaults as follows (no
local overrides needed):

| Zed | LazyVim | Action |
| --- | --- | --- |
| `space e` | `<leader>e` | file explorer |
| `space f` | `<leader><space>` / `<leader>ff` | find files |
| `space t` | `<leader>ft` | terminal |
| `space g` | `<leader>gg` | lazygit |
| `space o` | `<leader>cs` | symbols outline |
| `space d` | `<leader>xx` | diagnostics |
| `space s` | `<C-s>` | save |
| `space n` | `<leader>fn` | new file |
| `space w` | `<leader>bd` | close buffer |
| `space b` | `<leader>,` | buffers |
| `space *` | `<leader>/` | grep |
| `space r` | `<leader>cr` | rename |
| `space c` | `gcc` | toggle comment |
| `space x` | `<leader>ca` | code action |
| `space -` | `<leader>-` | split below |
| `space ;` | `:` | command line |
| `] b` / `[ b` | `]b` / `[b` | next / prev buffer |
| `tab` / `shift-tab` | `]b` / `[b` | next / prev buffer |

## CLI / alias

```zsh
command -v nvim >/dev/null && alias vim='nvim'
```

The managed alias already exists in `config/zsh/aliases.zsh`; no new wrapper is
installed. `nvim` is available directly from DNF.

## Setup phases

| Command | Behavior |
| --- | --- |
| `./bin/laptop-setup nvim` | Ensures Neovim presence (or dry-run note) and links the config |
| `./bin/laptop-setup config` | Calls the same `link_nvim_config` helper so relinks stay in sync |
| `./bin/laptop-setup apply` | Runs `nvim` after `zed` and still runs full `config` later |

Both paths use `link_config`, so a conflicting `~/.config/nvim` is backed up
under `~/.local/state/dotfiles-fedora/backups/`.

## Status

`./bin/laptop-setup status` reports the Neovim binary, the managed link state
for `~/.config/nvim`, and the managed `vim` alias definition.

## Validation

```bash
bash -n bin/laptop-setup lib/laptop-setup/nvim.sh
./bin/laptop-setup --help
./bin/laptop-setup --dry-run nvim
./bin/laptop-setup status
# headless smoke test (first run clones lazy.nvim + plugins):
nvim --headless "+Lazy! sync" +qa
nvim --headless "+Lazy! health" +qa
```

## Rollback

```bash
rm -f ~/.config/nvim
# restore from ~/.local/state/dotfiles-fedora/backups/<timestamp>/... if needed
# remove the vim alias from config/zsh/aliases.zsh or stop linking aliases
```

Runtime state can be cleared independently of the config:

```bash
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

Removing Neovim is out of band: `sudo dnf remove neovim`.
