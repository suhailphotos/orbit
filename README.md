# Orbit

Opinionated Zsh bootstrap for my machines. Orbit sets up a *fast* shell, detects tools on each host, exports a small set of environment variables, and gives me a handful of functions for day‑to‑day work (package jumping, Poetry/Conda activation, Houdini/Nuke helpers, git utilities, etc.).

> Nothing heavy runs on shell start. Houdini/Nuke/Python envs only initialize when you call their functions.

## Table of Contents

- [Quickstart](docs/Quickstart.md)
- [Environment Variables](docs/Environment_Vars.md)
- [Functions & Aliases](docs/Functions.md)
  - [Houdini: `hou` + Tessera packages](docs/Houdini.md)
  - [Nuke: `nukeUtils`](docs/Nuke.md)
- [Troubleshooting](docs/Troubleshooting.md)

---

## What Orbit Does

- **Bootstraps zsh** via `~/.zshrc` with a tiny git-backed repo at `$ORBIT_HOME`.
- **Detects platform/apps** (macOS/Linux/WSL; Houdini, Nuke) and exports handy flags.
- **Sets expected env vars** used by my downstream tools (Dropbox/Matrix roots, data libraries, AI mount points, etc.).
- **Loads small plugins**: colors/ls, search config, zoxide, terminfo, prompt (Starship or P10k).
- **Adds functions** for: package activation (`pkg`/`mkpkg`), Houdini (`hou`), Nuke (`nukeUtils`), Poetry/Conda project wrappers, git helpers, clipboard shims, terminfo deploy, etc.
- **Keeps secrets optional** via a `.env` file and/or 1Password CLI token.

## Repo Layout

```
core/         # bootstrap, detection, path helpers, secrets
modules/
  env/        # environment variables / PATH / toggles
  aliases/    # small alias sets (global, per-OS, per-host)
  functions/  # the fun stuff (pkg, hou, venv, git, etc.)
  prompt/     # starship or powerlevel10k
helpers/      # install script, terminfo helper
secrets/      # .env and optional 1Password token (ignored by git)
```

## Top-Level Commands (most used)

| Command | Description |
|---|---|
| `pkg <name\|path> [--hou [VER\|latest]] [--cd-only]` | Jump to a package and activate its Poetry env. If `--hou` is set (or the package is in `$HOU_PACKAGES`), first point Poetry at the SideFX Python for the selected Houdini version. |
| `mkpkg <name\|path> [--hou [VER]] [--alias NAME]` | Create a per-session helper function that wraps `pkg`. Great for quick shortcuts. |
| `hou <subcommand>` | SideFX/Houdini helper: version selection, Poetry interpreter wiring, user prefs, smoke‐testing `import hou`, package shim JSON, etc. See [docs/Houdini.md](docs/Houdini.md). |
| `nukeUtils [-e\|launch]` | Nuke env helper (mac by default). |
| `bindu_autosync_on/off/status` | Low‑overhead autosync for `~/.config` if that dir is a git repo. |
| `push_terminfo user@host [TERM]` | Copy this terminal’s terminfo to a remote host. |
| `terminfo_ok user@host [TERM]` | Check if a remote host knows this TERM. |
| `lazygit "msg" [branch]` | `git add . && git commit -m "msg" && git push origin branch`. |
| `merge_branch <src> <tgt>` | Fast-forward aware merge with a default message. |

## Houdini at a Glance

- You can use *SideFX’s* Python inside Poetry:
  ```sh
  # inside a Poetry project
  hou use                 # use latest installed Houdini
  hou use 21.0.440        # use a specific version
  ```
- To make Houdini see your project’s site‑packages, prefer a **Tessera package** or write a one‑off user package JSON:
  ```sh
  hou pkgshim             # writes $HOUDINI_USER_PREF_DIR/packages/98_poetry_site.json
  ```
- Need a quick `import hou` check (and optional license choice)?
  ```sh
  hou import --license hescape   # or --license batch
  ```

Read the full [Houdini guide](docs/Houdini.md) for details.
