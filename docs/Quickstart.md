# Quickstart

## Install

### One-liner

Add this to `~/.zshrc` (or run the installer below to write it for you):

```zsh
# Orbit bootstrap
export ORBIT_HOME="$HOME/.orbit"
export ORBIT_REMOTE="https://github.com/suhailphotos/orbit.git"
export ORBIT_BRANCH="main"
if [[ ! -d "$ORBIT_HOME/.git" ]]; then
  git clone --depth 1 --branch "$ORBIT_BRANCH" "$ORBIT_REMOTE" "$ORBIT_HOME"
fi
# optional silent fast-forward update (background)
( git -C "$ORBIT_HOME" fetch --quiet && git -C "$ORBIT_HOME" merge --ff-only "origin/$ORBIT_BRANCH" --quiet ) >/dev/null 2>&1 &!
source "$ORBIT_HOME/core/bootstrap.zsh"
```

Open a new terminal or `source ~/.zshrc`.

### Installer script (optional)

```bash
cd /tmp && curl -fsSLO https://raw.githubusercontent.com/suhailphotos/orbit/main/helpers/install.sh
bash install.sh --zshrc ask   # or: yes/no
```

The installer clones/updates the repo and (optionally) writes a template `~/.zshrc`.

## Secrets (optional)

- Put non‑secret defaults in: `"$ORBIT_HOME/secrets/.env"`
- If you use 1Password CLI, drop your token into: `"$ORBIT_HOME/secrets/op_token"`

Orbit will export keys from `.env` and can read secrets via `op://` URLs when present.

## Updating

The `.zshrc` bootstrap already fast‑forwards in the background. To force an update:

```zsh
git -C "$ORBIT_HOME" fetch && git -C "$ORBIT_HOME" merge --ff-only origin/main
```

## Design Notes

- Minimal work at shell start; most helpers do nothing until you call them.
- Per‑platform/per‑host glue lives in `modules/env/*` (e.g., CUDA/Conda on `nimbus`).
- Detection flags are exported (e.g., `ORBIT_HAS_HOUDINI=1`, `ORBIT_PLATFORM=mac`) so functions can behave conditionally.
