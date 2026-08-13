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
./bin/laptop-setup herdr
./bin/laptop-setup shell-tools
./bin/laptop-setup config
./bin/laptop-setup shell
```

Configuration deployment uses symlinks back into this checkout. An existing
target is moved first to a timestamped directory under
`~/.local/state/dotfiles-fedora/backups/`; it is never silently overwritten.

## Tmux and Sesh

Tmux uses `Ctrl+Space` as its prefix and a modular Vesper status bar. Press the
prefix twice to cancel it. The managed configuration preserves the active
directory in new windows and panes, enables the mouse and vi copy mode, and
copies selections to the Wayland clipboard with `wl-copy`.

Common bindings:

| Binding | Action |
| --- | --- |
| `Prefix h/j/k/l` | Navigate panes |
| `Prefix H/J/K/L` | Resize panes |
| `Prefix K` | Open the Sesh picker |
| `Prefix Tab` | Switch to the previous Sesh session |
| `Prefix r` | Reload the tmux configuration |
| `Prefix x` | Kill the active pane without confirmation |

The `t` shell function creates or attaches to the `home` session by default;
pass a name such as `t work` to create or attach another home-rooted session.
Use `tl` to open the Sesh picker and `tk` to stop the entire tmux server.

## Graphical login

The selected graphical login stack is Fedora's `greetd` with DMS Dank Greeter.
It launches the packaged niri session through `niri-session`, preserving niri's
systemd user-session and portal integration. Installation and activation are
deliberately separate:

```bash
laptop-setup login-manager
dms greeter status
laptop-setup login-manager-enable
```

The first command installs and synchronizes the greeter without changing the
boot target. The second checks for conflicting display managers, asks for
confirmation, enables greetd, and changes the default to `graphical.target`.

Before rebooting, keep a terminal open and confirm `dms greeter status` is
healthy. For recovery, switch to a TTY with `Ctrl+Alt+F3`, log in, and run:

```bash
sudo systemctl stop greetd.service
sudo systemctl disable greetd.service
sudo systemctl set-default multi-user.target
```

You can then start `niri-session` manually. To remove DMS Greeter configuration
and restore the display-manager state saved by DMS, run:

```bash
dms greeter uninstall --yes
```

## First-draft scope

- Alacritty with JetBrainsMono Nerd Font and the Vesper palette;
- `fd`, ripgrep, FZF, eza, Zoxide, Zsh, Starship, bat, btop, and fastfetch;
- local-only Atuin history with automatic sync, update checks, and its daemon disabled;
- Mise-managed Node.js with Pi, Codex, and a managed Pi statusline extension;
- pinned, directly sourced `zsh-autosuggestions` and
  `fast-syntax-highlighting` checkouts with no shell framework or plugin manager;
- Chromium from Fedora for browser app-mode launchers using
  `chromium-browser --app=URL`, plus a managed local policy that disables
  Chromium password saving, site notifications, and default-browser prompts;
- LocalSend from Flathub;
- Homebrew plus Dashlane CLI, Starship, `jless`, `fx`, Lazygit, Sesh, and `xh`;
- Herdr from its official verified installer; and
- managed Zsh, Starship, tmux, Sesh, bat, and fastfetch defaults.

Authentication, browser profiles, Dashlane sessions, shell history, SSH keys,
GNOME dconf state, caches, and generated runtime files must stay outside Git.
Chromium displays “Managed by your organization” because the setup installs
these local policies under `/etc/chromium/policies/managed/`.
