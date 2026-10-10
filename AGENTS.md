# Repository Guidelines

## Project Structure & Module Organization

This repository provides an idempotent Fedora laptop setup CLI. `bootstrap.sh` bootstraps the checkout. `bin/fedora-setup` dispatches setup phases in `lib/fedora-setup/*.sh`; shared helpers and constants belong in `common.sh`. Managed settings live under `config/`, static images in `assets/`, and operational guides in `docs/`.

When adding a phase, define an `install_<name>` function in a focused module, source it from `bin/fedora-setup`, add its command to `usage()` and `main()`, and place it correctly in the `apply` dependency order.

## Build, Test, and Development Commands

There is no build step. Validate changes from the repository root:

- `./bin/fedora-setup --help` checks CLI loading and command documentation.
- `./bin/fedora-setup status` reports current managed state.
- `./bin/fedora-setup --dry-run apply` previews setup without mutation (Fedora required).
- `./hooks/pre-commit` checks Bash syntax for each file and runs ShellCheck over `bootstrap.sh`, `bin/fedora-setup`, `bin/fedora-update`, `bin/fedora-sync`, the hook itself, `lib/fedora-setup/*.sh`, and `lib/fedora-setup/fonts/*.sh`. The development phase installs ShellCheck.
- The config phase links this hook into the checkout's Git hooks directory, including linked worktrees. Existing hooks are backed up before replacement. Desktop helper scripts and `lib/wallpaper.sh` remain outside this setup/update check.

Run a focused dry-run command, such as `./bin/fedora-setup --dry-run fonts`, for the phase you changed.

## Work Tracking

Use [GitHub Issues](https://github.com/bharatsuri1/dotfiles-fedora/issues) for roadmap items and reminders about work that cannot be done right away. Work can proceed without an issue or issue reference. Do not create issues for small ad hoc tasks unless the user asks. Check existing issues when useful to identify overlapping work, dependencies, or related decisions; an issue is not a prerequisite for implementation.

When an issue is requested, give it an outcome-oriented title and actionable scope. Use the `gh issue` CLI to manage issues. When work addresses an existing issue, update or close it as appropriate and record the outcome and relevant validation. Avoid parallel backlogs in repository files. Documentation should cover installation, troubleshooting, permissions, data preservation, and recovery; do not duplicate settings, shortcuts, versions, hashes, or implementation details available in config/code. Historical backlogs belong in Git history, not repository files.

## Coding Style & Naming Conventions

Use Bash with `#!/usr/bin/env bash` and `set -Eeuo pipefail`. Indent with two spaces. Name functions and local variables in `snake_case`; use `UPPER_SNAKE_CASE` for readonly globals. Prefer arrays for command arguments and quote every expansion. Route state-changing commands through the shared `run` helper so dry-run mode remains accurate. Keep operations idempotent: detect completed work, log it, and avoid silently overwriting user configuration.

## Testing Guidelines

No automated test framework or coverage threshold is currently configured. At minimum, run `bash -n`, ShellCheck, and relevant dry-run/status commands. Changes involving package managers, login services, or `/etc` should be manually verified on Fedora and include recovery considerations.

## Commit & Pull Request Guidelines

Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#specification): `<type>[optional scope]: <description>`. Use lowercase, imperative descriptions and focused commits; for example, `feat(ghostty): add managed configuration`, `fix(homebrew): handle absent brew`, `docs: clarify recovery steps`, or `chore: update defaults`. Use `feat` for new functionality and `fix` for bug fixes. Mark incompatible changes with `!` (for example, `feat!: remove legacy phase`) or a `BREAKING CHANGE:` footer, and explain non-obvious safety decisions in the body.

Pull requests should summarize changes, list validation, identify affected Fedora profiles, and include screenshots for visible changes. Link an existing issue when relevant; an issue reference is optional. Never commit secrets, history, browser profiles, caches, or runtime state.
