# Fedora laptop setup

An idempotent setup CLI and portable configuration for Fedora laptops. Setup
supports existing Fedora installations without owning disk layout, secrets,
or application data.

## Install

For ISO installation and Wi-Fi recovery, see [installation.md](docs/installation.md).
From a Fedora installation with working networking and an administrative user:

```bash
curl -fsSL https://raw.githubusercontent.com/bharatsuri1/dotfiles-fedora/main/bootstrap.sh | bash
```

Bootstrap installs Git if needed, clones into `~/.local/share/dotfiles-fedora`,
and starts guided setup. Use `DOTFILES_FEDORA_INSTALL_ROOT` or
`DOTFILES_FEDORA_REPOSITORY_URL` to override the checkout or repository.

## Use

```bash
fedora-setup status
fedora-setup --dry-run apply
fedora-setup apply
fedora-setup --help
fedora-update
fedora-sync
```

The installed setup wrapper fast-forwards the checkout from `origin/main`
before running a phase. To use the current checkout without fetching, run
`./bin/fedora-setup` from the repository root. Individual phases and flags are
listed by `--help`.

## Ownership

Read [config/](config/) for settings and shortcuts, [bin/](bin/) for commands,
and [lib/fedora-setup/](lib/fedora-setup/) for package ownership and setup behavior.
Edit managed settings in the checkout. Conflicting configuration is backed up
under `~/.local/state/dotfiles-fedora/backups/` before replacement.

Credentials, browser profiles, histories, caches, project trust records, and
application data remain local. Reverting this checkout does not automatically
undo package installation or service changes. Reapplying setup may restore
manually removed managed files and service attachments.

## Desktop recovery

Start `niri-session` from a TTY. If the launcher fails, run `fuzzel` from a
terminal. Validate Niri edits with `niri validate -c config/niri/config.kdl`.

SDDM activation is explicit: after testing TTY recovery, run
`fedora-setup sddm-enable`. If graphical boot fails, switch to a TTY, log in,
and run `sudo systemctl set-default multi-user.target` to restore console boot.
This changes the next boot target; it does not stop the current session.

To stop the optional bar, run `systemctl --user stop quickshell.service`.
Restore it with `systemctl --user start quickshell.service`; inspect failures
with `journalctl --user -u quickshell.service -b`.

## Operational guides

- [Device recovery](docs/device-controls.md)
- [Screenshot troubleshooting](docs/screenshots.md)
- [Dictation permissions and recovery](docs/voxtype.md)
- [VS Code recovery](docs/vscode.md)
- [Zed recovery](docs/zed.md)
