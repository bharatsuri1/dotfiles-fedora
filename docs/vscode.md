# Native VS Code

Tracked in [#69](https://github.com/bharatsuri1/dotfiles-fedora/issues/69), the
first application migration under #68.

## Installation and ownership

Run `./bin/fedora-setup --dry-run vscode` to preview, then
`./bin/fedora-setup --yes vscode` to install Microsoft's stable `code` RPM,
link managed settings/keybindings, and install missing allowlisted extensions.
Omit `--yes` to retain DNF's confirmation prompts, including signing-key import.

The phase installs `config/vscode/vscode.repo` at
`/etc/yum.repos.d/vscode.repo`. DNF imports the Microsoft signing key from the
configured `gpgkey` when needed and verifies packages with `gpgcheck=1`.
Conflicting repository files and user configuration are backed up beneath
`${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-fedora/backups/`.
Updates use DNF, including the existing `fedora-update` command.

Settings and keybindings are symlinked into `~/.config/Code/User/`.
Extensions are installed through `/usr/bin/code`; extra user-installed
extensions are preserved. Profiles, credentials, extension state, history,
and `~/.vscode/argv.json` remain local and outside Git.

The integrated terminal runs `/usr/bin/zsh -l` directly. Docker resolves from
the host PATH. Docker installation and permissions are managed by the separate
`docker` phase. Niri's `Super+Ctrl+V` launches `code`.

Official installation reference: https://code.visualstudio.com/docs/setup/linux

## Migration from Flatpak

This migration uses a fresh native installation: the user chose to skip data
backup and transfer, reinstall the managed extensions, and sign in again.
The setup phase does not uninstall the Flatpak or delete its data.

1. Save files and close VS Code before applying setup changes. The old Flatpak
   settings symlink points to the same repository settings, so changing the
   terminal profile also changes what that installation sees.
2. Preview and run the focused `vscode` phase. While both apps exist, launch
   `/usr/bin/code` explicitly. In an existing Zsh session, run `unalias code`
   if it still points to Flatpak; fresh shells load the updated aliases.
3. Verify Vesper, Vim bindings, accessibility support off, extensions,
   integrated Zsh/PATH/Mise, Git, and account sign-ins. Test Docker and reopening
   a project in a Dev Container, plus Remote SSH when applicable.
4. Verify the Niri shortcut, launcher entries, and Wayland window behavior.
   Inspect any user-created shortcuts or favorites referring to
   `com.visualstudio.code.desktop`. For URL associations, inspect
   `xdg-mime query default x-scheme-handler/vscode`; if it points to the old
   app, confirm the RPM's URL-handler desktop filename and use
   `xdg-mime default code-url-handler.desktop x-scheme-handler/vscode`.
5. Run the vscode phase again to verify idempotence, and inspect
   `./bin/fedora-setup status` and `rpm -q code`.
6. Once native VS Code works, manually uninstall the system Flatpak:

   ```bash
   flatpak uninstall --system com.visualstudio.code
   flatpak override --user --reset com.visualstudio.code
   ```

   Initially omit `--delete-data` to retain the old local data. Inspect
   `flatpak override --system --show com.visualstudio.code`; if app-specific
   system overrides exist, reset them with
   `sudo flatpak override --system --reset com.visualstudio.code`.
7. After confirming normal native use, optionally remove the old app data:

   ```bash
   rm -rf -- "$HOME/.var/app/com.visualstudio.code"
   ```

   This removes the old settings symlinks, not their repository sources.
   Leave other Flatpak applications and shared runtimes alone. Future setup
   runs no longer install the VS Code Flatpak.

## Rollback

Restore the previous repository version's VS Code module/settings, Flatpak
app list, Zsh alias, and Niri launcher. Reinstall the system app with
`flatpak install --system flathub com.visualstudio.code`, then run the restored
`vscode` phase to reapply Flatpak configuration and overrides. Retained
`~/.var/app/com.visualstudio.code` data can be reused; deleted local state must
be recreated because this migration does not make a backup.

Verify the restored Flatpak before removing the native package with
`sudo dnf remove code`. Remove the managed RPM repository or restore its
preexisting backup as appropriate. Preserve native local data until recovery
is confirmed.
