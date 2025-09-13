# Packages

A central place to list and manage my package helpers.

## Where the list lives

Edit the array in **`modules/env/45-projects.zsh`**:

```zsh
typeset -ga ORBIT_PROJECTS=(
  usdUtils
  oauthManager
  pythonKitchen
  ocioTools
  helperScripts
  Incept
  pariVaha
  Lumiera
  Ledu
  hdrUtils
)
```

On shell load, Orbit generates for each entry:

- A function named exactly like the project (e.g., `usdUtils`) that `cd`s into `$DROPBOX/matrix/packages/<name>` and activates its env (uv by default).
- A `publish_<name>` function (e.g., `publish_usdUtils`) that runs `uv build` and, if `twine` is available, uploads the artifacts.

> Linux hosts that export `ORBIT_USE_CONDA=1` will activate Conda instead for generic envs. Houdini‑specific flows still use `hou use` + uv.

## One‑off helpers

For ad‑hoc shortcuts (including projects not in `ORBIT_PROJECTS`), use `mkpkg`:

```zsh
mkpkg ~/Library/CloudStorage/Dropbox/matrix/packages/houdiniLab --hou --alias hlab
hlab   # now jumps + activates
```

Or call `pkg` directly:

```zsh
pkg ocioTools
pkg /abs/path/to/some/other/project
```
