# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

People who want an opinionated Fedora installation with a cohesive, ready-to-use laptop environment. The repository currently reflects its maintainer's daily workflow while being developed toward a packaged Fedora ISO.

## Product Purpose

Turn Fedora into a reproducible, inspectable, keyboard-driven Linux environment. Success means a user can install or reapply the system safely, reach a complete working desktop, and recover through a documented TTY path when a graphical component fails.

## Positioning

The product owns the full path from an idempotent Fedora setup CLI to an integrated niri and Quickshell desktop. It combines explicit package ownership, repository-managed configuration, guarded system changes, and recovery procedures instead of treating the desktop theme as an isolated configuration bundle.

## Operating Context

- Fedora installation profiles including Workstation, Server, and Minimal.
- A Wayland desktop session built around niri, Quickshell, SDDM, Mako, gtklock, Swayidle, Fuzzel, and systemd user services.
- Keyboard-first window management with touchpad and pointer support.
- Repeated setup runs, dry runs, state inspection, upgrades, and recovery from a TTY.
- Laptop displays today, with external and multi-monitor behavior planned for the niri and Quickshell surfaces.

## Capabilities and Constraints

- Fedora is the supported operating system and DNF owns native packages.
- Setup operations must remain idempotent and route mutations through the shared `run` helper.
- Existing user configuration is backed up before managed symlinks replace it.
- The desktop must remain usable if optional Quickshell UI is stopped or fails; Fuzzel and the bare niri session are recovery paths.
- Secrets, authentication sessions, browser profiles, shell history, caches, generated state, and other machine-specific runtime data stay outside Git.
- Niri and Quickshell are the current focus for product design principles and refinement.
- The Impeccable platform vocabulary does not currently include native Linux desktop software; `web` is recorded above as its non-mobile fallback, while the actual target is Fedora Linux.

## Brand Commitments

- Fedora is the distribution foundation.
- Vesper is the visual identity.
- Interaction is keyboard-driven without removing essential pointer, touchpad, or recovery paths.

## Evidence on Hand

- `README.md` documents the bootstrap, setup phases, managed scope, desktop architecture, and recovery paths.
- `config/niri/config.kdl` and `config/quickshell/shell.qml` are the current desktop surfaces.
- `config/alacritty/themes/vesper.toml`, `config/sddm/themes/vesper/`, and the managed desktop configuration provide incumbent Vesper implementation evidence.
- `docs/dms-removal-plan.md` and `docs/quickshell-foundation.md` record migration, architecture, lifecycle, fallback, and validation decisions.
- [GitHub Issues](https://github.com/bharatsuri1/dotfiles-fedora/issues) is the authoritative tracker for implementation and validation work; `archive/TODO.md` is retained only as a deprecated historical snapshot.
- No testimonials, external adoption evidence, performance benchmarks, or release claims are established and future work must not fabricate them.

## Product Principles

1. Make strong defaults coherent across the whole installation, not merely attractive in isolation.
2. Put the keyboard path first while preserving accessible, discoverable, and reliable alternatives.
3. Prefer event-driven, system-integrated components with explicit ownership and bounded resource use.
4. Keep every system change inspectable, repeatable, and recoverable.
5. Treat the compositor as the dependable foundation and the custom shell as an enhancement that may fail independently.

## Accessibility & Inclusion

Preserve niri's keyboard navigation and hotkey discoverability, visible focus, screen-reader-compatible session startup, reduced-motion paths where implemented, and graceful behavior for long or localized content. Specific conformance targets remain undecided.
