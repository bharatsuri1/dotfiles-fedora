# Repository Guidelines

## Project Structure & Module Organization

This repository provides an idempotent Fedora laptop setup CLI. `bootstrap.sh` bootstraps the checkout. `bin/laptop-setup` dispatches setup phases in `lib/laptop-setup/*.sh`; shared helpers and constants belong in `common.sh`. Managed settings live under `config/`, static images in `assets/`, and plans in `docs/`.

When adding a phase, define an `install_<name>` function in a focused module, source it from `bin/laptop-setup`, add its command to `usage()` and `main()`, and place it correctly in the `apply` dependency order.

## Build, Test, and Development Commands

There is no build step. Validate changes from the repository root:

- `./bin/laptop-setup --help` checks CLI loading and command documentation.
- `./bin/laptop-setup status` reports current managed state.
- `./bin/laptop-setup --dry-run apply` previews setup without mutation (Fedora required).
- `shellcheck bootstrap.sh bin/laptop-setup lib/laptop-setup/*.sh lib/laptop-setup/fonts/*.sh` performs static Bash analysis when ShellCheck is installed.
- `bash -n bootstrap.sh bin/laptop-setup lib/laptop-setup/*.sh lib/laptop-setup/fonts/*.sh` checks shell syntax.

Run a focused dry-run command, such as `./bin/laptop-setup --dry-run fonts`, for the phase you changed.

## Work Tracking

Use [GitHub Issues](https://github.com/bharatsuri1/dotfiles-fedora/issues) as the authoritative repository tracker; do not maintain a parallel backlog in repository files or leave deferred work only in code comments. Use the `gh issue` CLI to list, view, create, update, and close tickets. Before starting tracked work, review the relevant open issue and keep its scope and acceptance criteria current.

Create issues with an outcome-oriented title and actionable checkboxes. Record dependencies, validation, and rollback work when relevant. Put lengthy designs in `docs/` and link them from the issue. Link implementation work to its issue, and close the issue only after recording the completed outcome and validation. `archive/TODO.md` is a deprecated historical snapshot and must not be updated or used for new work.

## Coding Style & Naming Conventions

Use Bash with `#!/usr/bin/env bash` and `set -Eeuo pipefail`. Indent with two spaces. Name functions and local variables in `snake_case`; use `UPPER_SNAKE_CASE` for readonly globals. Prefer arrays for command arguments and quote every expansion. Route state-changing commands through the shared `run` helper so dry-run mode remains accurate. Keep operations idempotent: detect completed work, log it, and avoid silently overwriting user configuration.

## Testing Guidelines

No automated test framework or coverage threshold is currently configured. At minimum, run `bash -n`, ShellCheck, and relevant dry-run/status commands. Changes involving package managers, login services, or `/etc` should be manually verified on Fedora and include recovery considerations.

## Commit & Pull Request Guidelines

Use short, imperative subjects such as `Add managed Chromium privacy defaults`. Keep commits focused and explain non-obvious safety decisions in the body. Pull requests should summarize changes, list validation, identify affected Fedora profiles, and include screenshots for visible changes. Never commit secrets, history, browser profiles, caches, or runtime state.
