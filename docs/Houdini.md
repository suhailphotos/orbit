# Houdini

Helpers to keep **uv** environments aligned with SideFX’s bundled Python, without hard‑coding paths or package names.

> By design, nothing runs at shell init. You call `hou` when you actually need Houdini.

## Quick Examples

```sh
# 1) Use SideFX Python in the current project (creates external uv env)
hou use              # uses latest installed version
hou use 21.0.440     # pin to a specific version

# 2) Make Houdini see this project’s site‑packages
hou pkgshim          # writes $HOUDINI_USER_PREF_DIR/packages/98_uv_site.json

# 3) Smoke‑test 'import hou' (optional license type)
hou import --license hescape        # or --license batch
hou import 21.0.440 --release       # release the license after the test
```

## How Version Selection Works

- `hou versions` scans installed builds (`/Applications/Houdini/Houdini*` on mac, `/opt/hfs*` on Linux).
- If you pass a version (`21.0.440`), it uses that.
- Otherwise it prefers `ORBIT_HOUDINI_VERSION` (from startup detection) or falls back to the newest on disk.

## Commands

| Command | What it does |
|---|---|
| `hou versions` | List installed versions (new → old). |
| `hou python  [VER\|latest]` | Print the absolute path to the SideFX Python for that version. |
| `hou prefs   [VER\|latest]` | Export `HOUDINI_USER_PREF_DIR` to the versioned user prefs (`~/Library/Preferences/houdini/21.0` on mac; `~/houdini21.0` on Linux). |
| `hou use     [VER\|latest]` | Create/recreate an **external uv env** at `~/.venvs/<project>` using the SideFX Python, then activate it. |
| `hou pkgshim [VER\|latest]` | Write a dev JSON package at `$HOUDINI_USER_PREF_DIR/packages/98_uv_site.json` that appends your env’s `site‑packages` to `PYTHONPATH`. |
| `hou patch   [VER\|latest]` | (Legacy) Append `PYTHONPATH` to `houdini.env` instead of using packages JSON. |
| `hou import  [VER\|latest] [--license hescape\|batch] [--release]` | Source `houdini_setup` and run a quick `import hou` using SideFX Python. |
| `hou env     [VER\|latest]` | Source `houdini_setup` into this shell (sets `HFS`, `HHP`, etc.). |
| `hou doctor  [VER\|latest]` | Print resolved paths and whether `houdini_setup` sources cleanly. |

### Notes

- **uv‑only by default.** On Linux hosts that set `ORBIT_USE_CONDA=1` (e.g., `nimbus`), Orbit will prefer Conda for generic env activation. `hou use` always builds an external **uv** env since it needs the exact SideFX Python.  
- **Packages JSON (preferred).** Use Tessera (versioned) or `hou pkgshim` (quick) to expose your env to Houdini at runtime.
- **Licenses.** `hou import` checks out a license; `--release` calls `hou.releaseLicense()` afterwards.

## Integrating With `pkg`

If a package typically needs Houdini, add it to `HOU_PACKAGES` in `secrets/.env`:

```sh
HOU_PACKAGES=(houdiniLab houdiniUtils)
```

Then a simple `pkg houdiniLab` will:

1) run `hou use latest` (or `--hou <VER>` if you pass it),  
2) `cd` into the package, and  
3) activate the env.

```sh
pkg houdiniLab --hou           # ensure SideFX Python then activate
pkg houdiniLab --hou 21.0.440  # force a specific build
```
