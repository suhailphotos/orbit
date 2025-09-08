# Nuke

Lightweight helper for launching/working with Nuke projects.

## Commands

| Command | What it does |
|---|---|
| `nukeUtils -e` | Activate Poetry env for `nukeUtils`, create `~/.nuke` if needed, and append `plugins/` to `NUKE_PATH`. |
| `nukeUtils launch` | Launch Nuke (`Nuke`, `NukeX`, or `NukeStudio`), using the discovered default or your overrides. |

### Environment

- `NUKE_USER_DIR` defaults to `~/.nuke`.
- `NUKE_PATH` gets the package’s `plugins` directory prepended if it exists.
- Detected version/edition are available as `ORBIT_NUKE_DEFAULT` and `ORBIT_NUKE_EDITIONS`.
