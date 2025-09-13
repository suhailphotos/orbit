# Functions & Aliases

This is the human‑sized index. See the linked pages for deep dives.

## Package Navigation & Envs

| Command | What it does |
|---|---|
| `pkg <name\|path> [--hou [VER\|latest]] [--cd-only]` | Jump to a package under `$MATRIX/packages`, optionally ensure SideFX Python first, then activate the **uv** env (stored at `~/.venvs/<repo>`). |
| `mkpkg <name\|path> [--hou [VER]] [--alias NAME]` | Define a quick per‑session function that wraps `pkg`. Example: `mkpkg houdiniLab --hou` then just run `houdiniLab`. |
| Helpers from `ORBIT_PROJECTS` | For each name in `ORBIT_PROJECTS` (see [Packages](Packages.md)), Orbit generates a function that `cd`s into the project and activates its env (uv by default; Conda on hosts that set `ORBIT_USE_CONDA=1`). |
| `publish_<name>` | For each project in `ORBIT_PROJECTS`, Orbit also creates a `publish_<name>` helper that runs `uv build` and (optionally) `twine upload`. |

**Tip:** Packages that normally need Houdini can be listed in `HOU_PACKAGES` (array) via `secrets/.env`:
```sh
HOU_PACKAGES=(houdiniLab houdiniUtils)
```

## Houdini

See: [docs/Houdini.md](Houdini.md).

| Command | Summary |
|---|---|
| `hou versions` | List installed Houdini versions (new → old). |
| `hou python  [VER\|latest]` | Print the SideFX Python path for a version. |
| `hou prefs   [VER\|latest]` | Export `HOUDINI_USER_PREF_DIR` for that version. |
| `hou use     [VER\|latest]` | Create/recreate an external **uv** env (`~/.venvs/<project>`) using SideFX Python and activate it. |
| `hou pkgshim [VER\|latest]` | Write `$HOUDINI_USER_PREF_DIR/packages/98_uv_site.json` to add the project’s site‑packages at runtime. |
| `hou patch   [VER\|latest]` | (Legacy) Append site‑packages to `houdini.env` instead of using a package JSON. |
| `hou import  [VER\|latest] [--license hescape\|batch] [--release]` | Smoke‑test `import hou`. |
| `hou env     [VER\|latest]` | Source `houdini_setup` into the current shell (sets HFS/HHP/etc.). |
| `hou doctor  [VER\|latest]` | Print resolved paths and a quick `houdini_setup` check. |

## Nuke

See: [docs/Nuke.md](Nuke.md).

| Command | Summary |
|---|---|
| `nukeUtils -e` | Activate **uv** env for `nukeUtils`, set `NUKE_USER_DIR`, add `plugins` to `NUKE_PATH`. |
| `nukeUtils launch` | Launch the app (`Nuke`, `NukeX`, or `NukeStudio`). |

## Git

| Command | Summary |
|---|---|
| `lazygit "msg" [branch]` | Add, commit, and push to `origin/<branch>` in one go. |
| `merge_branch <src> <tgt>` | Fast‑forward aware merge with a default message. |

## Terminfo Utilities

| Command | Summary |
|---|---|
| `push_terminfo user@host [TERM]` | Send this terminal’s definition to a host. |
| `terminfo_ok user@host [TERM]` | Check whether a host knows a terminfo entry. |

## Misc

| Command | Summary |
|---|---|
| `prompt_doctor` | Show quick prompt diagnostics (TERM, size, locale, etc.). |
| `y` / `yy` / `yya` | Yazi file manager helpers (if installed). |
| Linux/WSL: `pbcopy`, `pbpaste` | Clipboard shims that pick Wayland/X11/OSC52/WSL. |

## Aliases

**Global**: `orbit`, `bindu`, `helix`, `lilac`, `tessera`, `packages`, `lg`, `gs`, `mira`  
**mac**: `o='open .'` — **linux**: `o='xdg-open .'`  
**host nimbus**: `nvidia`, `gpustats`
