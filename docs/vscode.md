# VS Code recovery

If a launcher opens the wrong installation, run `/usr/bin/code` explicitly and
inspect shell aliases, desktop favorites, and any remaining Flatpak entry.
For URL handling, inspect `xdg-mime query default x-scheme-handler/vscode`
and confirm the installed RPM's desktop filename before changing the association.

Native credentials, profiles, extension state, and history stay local. Back them
up while VS Code is closed before attempting a reinstall or migration. Setup
links managed settings; deleting a local symlink does not delete its repository
source. Reapplying setup recreates it.

DNF handles package updates. If installation fails on signing-key import or a
conflicting repository, resolve that error without disabling verification.
Conflicting managed files are backed up under
`~/.local/state/dotfiles-fedora/backups/`.

To remove the native package, close VS Code and run `sudo dnf remove code`.
Retain native data until recovery is confirmed. Remove the managed repository
file only after checking whether it replaced a preexisting file that should be
restored from backup. Remove VS Code from managed setup before reapplying it,
otherwise setup reinstalls the package.
