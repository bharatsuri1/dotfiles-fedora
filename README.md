# Fedora laptop setup

An idempotent, inspectable setup CLI and portable configuration for the Fedora
laptop. It works across Fedora installation profiles—including Workstation,
Server, and Minimal—while safely detecting and preserving work already done on
the machine. It does not depend on a particular preinstalled desktop and does
not own OS installation, disk layout, secrets, or application state.

The package and ownership choices are derived from the adjacent
`dotfiles-omarchy` decision ledger. Fedora/DNF owns native tools and Chromium;
Flatpak owns LocalSend, OpenCode, Visual Studio Code, and Zed; Homebrew owns
Dashlane CLI, Starship, `jless`, and `fx`; and Nerd Fonts owns the pinned
JetBrains Mono archive.

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
./bin/laptop-setup fonts        # terminal, system UI, and fallback families
./bin/laptop-setup flatpaks
./bin/laptop-setup homebrew
./bin/laptop-setup herdr
./bin/laptop-setup niri
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

## Desktop session

The managed baseline installs niri from Fedora repositories and keeps it usable
with a lightweight, repository-owned Quickshell top bar layered on the
independent session. Start `niri-session` from a TTY; `Mod+Space` launches
Fuzzel as the recovery-capable application launcher, and `Mod+Shift+L` locks the
session. Mako owns notifications, Swayidle owns idle and lock-before-sleep
behavior, gtklock owns authentication, and LXQt PolicyKit supplies graphical
authorization prompts. Quickshell runs as one systemd user service attached to
`niri.service` and renders the minimal top bar via the Wayland layer-shell
protocol; it is optional and can be stopped without disturbing the session.
These services are attached to `niri.service` and stop with the graphical
session. Swaybg renders the repository-owned wallpaper used by SDDM and gtklock
throughout the desktop session.

The proportional desktop UI uses Inter with Noto for multilingual, CJK, and
emoji fallback; terminal and code surfaces retain JetBrains Mono. The research,
role split, and foreground gtklock comparison command are documented in
[`docs/system-ui-fonts.md`](docs/system-ui-fonts.md).

`laptop-setup apply` installs and configures SDDM with the repository-owned
Vesper theme, wallpaper, and user picture, but does not activate it. After
testing the TTY recovery path, run `laptop-setup sddm-enable`; the guarded
command validates the niri session and managed theme, refuses to replace a
different enabled display manager, and switches the next boot to
`graphical.target`. It does not stop the current session. From a recovery TTY,
restore console boot with
`sudo systemctl set-default multi-user.target`.

The staged transition from an existing DMS installation, including TTY recovery
and greeter rollback instructions, is documented in
[`docs/dms-removal-plan.md`](docs/dms-removal-plan.md). The Quickshell
foundation, package source, lifecycle, and fallback model are documented in
[`docs/quickshell-foundation.md`](docs/quickshell-foundation.md). Do not remove
an active greeter or DMS packages until the independent niri session has been
tested.

## First-draft scope

- Inter for system UI, Noto for broad fallback, and JetBrainsMono Nerd Font for
  Alacritty and code/data roles, all within the Vesper palette;
- `fd`, ripgrep, FZF, eza, Zoxide, Zsh, Starship, bat, btop, and fastfetch;
- local-only Atuin history with automatic sync, update checks, and its daemon disabled;
- Mise-managed Node.js with Pi and Codex, a managed Pi statusline extension,
  and a portable Codex profile selected by the `cx` alias;
- pinned, directly sourced `zsh-autosuggestions` and
  `fast-syntax-highlighting` checkouts with no shell framework or plugin manager;
- Chromium from Fedora for browser app-mode launchers using
  `chromium-browser --app=URL`, plus a managed local policy that disables
  Chromium password saving, site notifications, and default-browser prompts;
- LocalSend, OpenCode, Visual Studio Code, and Zed from Flathub;
- Homebrew plus Dashlane CLI, Starship, `jless`, `fx`, Lazygit, Sesh, and `xh`;
- Herdr from its official verified installer;
- niri with Fuzzel as its independent baseline launcher; and
- a minimal, repository-owned Quickshell top bar layered on the session.
- managed Zsh, Starship, tmux, Sesh, bat, and fastfetch defaults.

Authentication, browser profiles, Dashlane sessions, shell history, SSH keys,
Codex project trust records, GNOME dconf state, caches, and generated runtime
files must stay outside Git.
Chromium displays “Managed by your organization” because the setup installs
these local policies under `/etc/chromium/policies/managed/`.
