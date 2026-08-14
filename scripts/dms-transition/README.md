# Temporary DMS transition helpers

These scripts support the one-time migration from DMS to the repository-owned
bare-niri baseline. They are intentionally separate from `laptop-setup` and
should be removed after the migration and final absence checks are complete.
Follow the complete supervised sequence in
[`docs/dms-uninstall-guide.md`](../../docs/dms-uninstall-guide.md).

Run them from any directory using their repository paths:

```bash
./scripts/dms-transition/status.sh
./scripts/dms-transition/detach.sh --dry-run
./scripts/dms-transition/detach.sh
./scripts/dms-transition/verify-baseline.sh
./scripts/dms-transition/preview-removal.sh
./scripts/dms-transition/cleanup-user-state.sh --dry-run
./scripts/dms-transition/cleanup-user-state.sh
```

The manual recovery boundaries remain:

1. Open and authenticate on a second TTY before detaching DMS.
2. Log out of the graphical session, stop greetd from the TTY, and start
   `niri-session` manually.
3. Validate visible desktop behavior; `verify-baseline.sh` covers services only.
4. Run `dms greeter uninstall --yes` while the CLI still exists.
5. Reboot into a TTY and prove `niri-session` again.
6. Review the DNF preview and manually accept package removal.
7. Review and remove Quickshell and greetd separately if they are not retained.
8. Disable the AvengeMedia COPRs only after no retained package needs them.
9. Reverse greeter group membership and named ACLs only after inspecting their
   exact current state; never reset home-directory permissions recursively.

`cleanup-user-state.sh` deliberately handles only known exported user paths. It
does not modify `/etc`, `/var`, repositories, groups, ACLs, packages, services,
or the boot target.
