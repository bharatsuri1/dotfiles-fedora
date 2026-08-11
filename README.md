# Fedora laptop setup

An idempotent, inspectable setup CLI and portable configuration for the Fedora
Workstation laptop. This repository starts from an already-running Fedora 44
GNOME installation; it does not assume a blank machine and it does not own OS
installation, disk layout, GNOME defaults, secrets, or application state.

The package and ownership choices are derived from the adjacent
`dotfiles-omarchy` decision ledger. Fedora/DNF owns native tools, Flatpak owns
Zen Browser and LocalSend, Homebrew owns Dashlane CLI, `jless`, and `fx`, and
Nerd Fonts owns the pinned JetBrains Mono archive.

## CLI

Inspect what is already complete:

```bash
./bin/laptop-setup status
```

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
./bin/laptop-setup font
./bin/laptop-setup flatpaks
./bin/laptop-setup homebrew
./bin/laptop-setup config
./bin/laptop-setup shell
```

Configuration deployment uses symlinks back into this checkout. An existing
target is moved first to a timestamped directory under
`~/.local/state/dotfiles-fedora/backups/`; it is never silently overwritten.

## First-draft scope

- Alacritty with JetBrainsMono Nerd Font and the Vesper palette;
- `fd`, ripgrep, FZF, eza, Zoxide, Zsh, Starship, bat, btop, and fastfetch;
- Zen Browser and LocalSend from Flathub;
- Homebrew plus Dashlane CLI, `jless`, and `fx`; and
- small Zsh, Starship, bat, and fastfetch defaults.

Authentication, browser profiles, Dashlane sessions, shell history, SSH keys,
GNOME dconf state, caches, and generated runtime files must stay outside Git.
