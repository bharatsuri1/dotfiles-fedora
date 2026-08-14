# Codex and Herdr configuration research

No changes were made.

The strongest Herdr finding is that you do not need a custom shell command to delete a worktree. Herdr 0.8.0 has a built-in, currently unbound action:

```toml
[keys]
remove_worktree = "prefix+shift+x"
```

`keys.remove_worktree` deletes the selected Herdr-managed worktree only after confirmation. This is safer and more context-aware than binding `git worktree remove` yourself. The installed binary and the current [Herdr configuration reference](https://herdr.dev/docs/config-reference/) agree that the action is unset by default.

I would use `prefix+shift+x`:

- `prefix+x` already closes a pane.
- `prefix+shift+x` is a natural destructive counterpart.
- The confirmation step remains in place.
- It does not collide with the current default Herdr map.

Herdr also supports multiple bindings per action:

```toml
[keys]
remove_worktree = [
  "prefix+shift+x",
  "ctrl+alt+shift+x",
]
```

However, I recommend starting with only the prefixed binding. Herdr recommends `ctrl+alt` for direct shortcuts, but destructive actions benefit from the deliberate prefix sequence. See [Herdr keyboard guidance](https://herdr.dev/docs/keyboard/) and [configuration/keybinding syntax](https://herdr.dev/docs/configuration/#keybindings).

The related built-in actions are:

```toml
[keys]
new_worktree = "prefix+shift+g" # existing default
open_worktree = "prefix+shift+o" # optional example
remove_worktree = "prefix+shift+x"
```

The CLI equivalent is:

```text
herdr worktree remove --workspace ID [--force]
```

`--force` should not be part of a routine keybinding because it can discard a dirty checkout.

For Codex, these are the sensible portable defaults for this Fedora + Herdr setup:

```toml
personality = "pragmatic"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
web_search = "live"

[sandbox_workspace_write]
network_access = true

[shell_environment_policy]
ignore_default_excludes = false

[features]
hooks = true

[tui]
alternate_screen = "never"
resume_cwd = "current"
```

Why these choices:

- `personality = "pragmatic"`: compact, implementation-oriented communication.
- `approval_policy = "on-request"`: Codex can work autonomously within its sandbox but asks before escalation.
- `sandbox_mode = "workspace-write"`: permits normal repository work without defaulting to unrestricted filesystem access.
- `network_access = true`: allows package/documentation checks from sandboxed commands.
- `web_search = "live"`: fits your frequent current-documentation and software research workflow.
- `ignore_default_excludes = false`: filters environment variables with names suggesting keys, secrets, or tokens. This is safer, though tools that depend on inherited credentials may need explicit handling.
- `hooks = true`: required for the existing Herdr session integration.
- `alternate_screen = "never"`: worth using inside Herdr so Codex output remains in terminal scrollback. This is the one preference I would test interactively before committing.
- `resume_cwd = "current"`: when resuming a thread from a worktree, remain in the worktree from which Codex was launched instead of prompting about the old session directory.

These settings are documented in the official [Codex configuration reference](https://developers.openai.com/codex/config-reference/).

I would not manage these globally:

- `model`: model availability and recommended defaults change.
- `model_reasoning_effort`: better selected per task or profile.
- `service_tier`: can affect usage/cost behavior.
- `projects."/absolute/path"` trust records: machine- and checkout-specific.
- `notify`: Herdr already integrates through Codex lifecycle hooks.
- Experimental feature flags: unnecessary churn for an idempotent laptop setup.
- `hooks.json` or `herdr-agent-state.sh`: Herdr currently owns and updates those files.

One architectural issue remains: if setup symlinks the entire `~/.codex/config.toml`, Codex may later need to store machine-local project trust entries there. That could modify the repository-backed file. The implementation should account for portable settings plus local mutable trust state instead of assuming the TOML will always remain purely portable.
