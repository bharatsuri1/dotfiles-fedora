# Fedora laptop setup

An idempotent, inspectable setup CLI and portable configuration for the Fedora
laptop. It works across Fedora installation profiles—including Workstation,
Server, and Minimal—while safely detecting and preserving work already done on
the machine. It does not depend on a particular preinstalled desktop and does
not own OS installation, disk layout, secrets, or application state.

The package and ownership choices are derived from the adjacent
`dotfiles-omarchy` decision ledger. Fedora/DNF owns native tools and Chromium,
Flatpak owns LocalSend, Homebrew owns Dashlane CLI, Starship, `jless`, and `fx`,
and Nerd Fonts owns the pinned JetBrains Mono archive.

## One-line bootstrap

From any Fedora installation with working networking and an administrative
user, run:

```bash
curl -fsSL https://raw.githubusercontent.com/bharatsuri1/dotfiles-fedora/main/bootstrap.sh | bash
```

The bootstrap installs Git if necessary, clones this repository under
`~/.local/share/dotfiles-fedora`, and starts the guided setup. Prompts read from
the terminal even though the bootstrap itself arrives through standard input.
Set `DOTFILES_FEDORA_INSTALL_ROOT` or `DOTFILES_FEDORA_REPOSITORY_URL` before
the command to override the checkout location or repository URL.

To exercise the hosted bootstrap without changing the machine:

```bash
curl -fsSL https://raw.githubusercontent.com/bharatsuri1/dotfiles-fedora/main/bootstrap.sh \
  | bash -s -- --dry-run apply
```

## CLI

After bootstrapping, run or rerun the complete setup with:

```bash
laptop-setup
```

Inspect what is already complete with `laptop-setup status`.

Preview all missing work without changing the machine:

```bash
./bin/laptop-setup --dry-run apply
```

Apply the complete first-draft setup interactively:

```bash
./bin/laptop-setup apply
```

Use `--yes` to accept package-manager prompts and the login-shell change. Each
phase can also run independently:

```bash
./bin/laptop-setup packages
./bin/laptop-setup fonts
./bin/laptop-setup flatpaks
./bin/laptop-setup homebrew
./bin/laptop-setup shell-tools
./bin/laptop-setup config
./bin/laptop-setup shell
```

Configuration deployment uses symlinks back into this checkout. An existing
target is moved first to a timestamped directory under
`~/.local/state/dotfiles-fedora/backups/`; it is never silently overwritten.

## First-draft scope

- Alacritty with JetBrainsMono Nerd Font and the Vesper palette;
- `fd`, ripgrep, FZF, eza, Zoxide, Zsh, Starship, bat, btop, and fastfetch;
- local-only Atuin history with automatic sync, update checks, and its daemon disabled;
- pinned, directly sourced `zsh-autosuggestions` and
  `fast-syntax-highlighting` checkouts with no shell framework or plugin manager;
- Chromium from Fedora for browser app-mode launchers using
  `chromium-browser --app=URL`;
- LocalSend from Flathub;
- Homebrew plus Dashlane CLI, Starship, `jless`, `fx`, and Lazygit; and
- small Zsh, Starship, bat, and fastfetch defaults.

Authentication, browser profiles, Dashlane sessions, shell history, SSH keys,
GNOME dconf state, caches, and generated runtime files must stay outside Git.
