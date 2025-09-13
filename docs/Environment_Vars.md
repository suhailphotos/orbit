# Environment Variables

Orbit exports a small, predictable set of variables. Values are platform‑aware where noted.

> Variables marked *(detected)* come from startup probes and may be empty on machines where the app is not installed.

## Core / Detection

| Variable | Example | Notes |
|---|---|---|
| `ORBIT_HOME` | `~/.orbit` | Repo root. |
| `ORBIT_PLATFORM` | `mac`, `linux`, `wsl`, `other` | From `detect_platform.zsh`. |
| `ORBIT_HOST` | `nimbus` | Short hostname. |
| `ORBIT_HAS_HOUDINI` | `0/1` | *(detected)* |
| `ORBIT_HOUDINI_ROOT` | `/Applications/Houdini/Houdini21.0.440/...` | *(detected)* |
| `ORBIT_HOUDINI_VERSION` | `21.0.440` | *(detected)* |
| `ORBIT_HAS_NUKE` | `0/1` | *(detected)* |
| `ORBIT_NUKE_DEFAULT` | `Nuke15.0v4` | *(detected)* |
| `ORBIT_NUKE_EDITIONS` | `Nuke NukeX NukeStudio` | Available editions. |
| `ORBIT_UV_VENV_ROOT` | `~/.venvs` | Base dir for all per‑project uv envs. |
| `ORBIT_UV_DEFAULT_PY` | `auto-houdini / 3.12 / /usr/local/bin/python3.12` | Fallback interpreter when a project doesn’t specify one. `auto-houdini` derives MAJOR.MINOR from the installed Houdini Python.|

## Paths / Projects

| Variable | macOS | Linux | Notes |
|---|---|---|---|
| `DROPBOX` | `~/Library/CloudStorage/Dropbox` | `~/Dropbox` | Base for Matrix. |
| `MATRIX` | `$DROPBOX/matrix` | same | Project root. |
| `DOCKER` | `$MATRIX/docker` | same | |
| `BASE_DIR` | `$MATRIX/shellscripts` | same | |
| `DATALIB` | `~/Library/CloudStorage/SynologyDrive-dataLib` | `/mnt/dataLib` | Synology data library. |
| `ML4VFX` | `$DATALIB/threeD/courses/05_Machine_Learning_in_VFX` | same | |
| `OBSIDIAN` | `$MATRIX/obsidian/jnanaKosha` | same | |

## Houdini

| Variable | Example | Notes |
|---|---|---|
| `ORBIT_HOUDINI_PREF_DEFAULT` | `~/Library/Preferences/houdini/21.0` | Default prefs path for detected version (mac) or `~/houdini21.0` on Linux. |
| `HOUDINI_USER_PREF_DIR` | *varies* | Set by `hou prefs` or implicitly by Houdini. |

## Search / Colors / Prompt

| Variable | Example | Notes |
|---|---|---|
| `RIPGREP_CONFIG_PATH` | `~/.config/ripgrep/ripgreprc` | If present. |
| `FD_OPTIONS` | `--hidden --ignore-file=~/.config/search/ignore` | If present. |
| `LESS` | `-R` | Color‑safe pager. |
| `PAGER` | `less` | |
| `EZA_CONFIG_DIR` | `~/.config/eza` | eza theme dir; icons toggle via `ORBIT_LS_ICONS`. |
| `ORBIT_USE_EZA` | `1` | Toggle eza vs. ls. |
| `ORBIT_LS_ICONS` | `0/1` | Icons toggle for eza. |
| `ORBIT_DOTFILES_SGR` | `90` | Dim dotfiles with eza. |
| `MANPAGER` | `col -bx \| bat -l man -p` | If `bat` exists. |
| `TERMINFO_DIRS` | `~/.terminfo:/usr/share/terminfo` | Ensures per‑user db first. |
| `LANG`, `LC_CTYPE` | `C.UTF-8` or system UTF‑8 | Set late to ensure UTF‑8. |

## AI Mounts

| Variable | Example | Notes |
|---|---|---|
| `NEBULA_AI_ROOT` | `/Volumes/ai` | Varies by platform. |
| `NEBULA_AI_MODELS`, `NEBULA_AI_DATASETS`, … | `${NEBULA_AI_ROOT}/models`, etc. | Exported only if the mount exists. |

## macOS Specific

| Variable | Example | Notes |
|---|---|---|
| `PYENV_ROOT` | `~/.pyenv` | pyenv initialization (if installed). |
| `NVIM_BG` | `light` or `dark` | Follows macOS appearance unless overridden. |
