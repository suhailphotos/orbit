# Troubleshooting

## Houdini

- **`hou use` says "Not inside a project".**  
  Run it from a directory that contains `pyproject.toml`, or set `HOU_PROJECT_ROOT=/abs/path`.

- **`hou import` fails with missing symbols on macOS.**  
  Make sure `houdini_setup` was successfully sourced by `hou import` (or run `hou env` first).

- **Houdini can’t see my module.**  
  Prefer a packages JSON (Tessera) or run `hou pkgshim` to append your env’s `site‑packages` to `PYTHONPATH` at runtime.

## `pkg` / uv

- **No env yet.**  
  `pkg` (and `hou use`) will create the env on first run using `uv venv` + `uv sync`.

- **Switching projects frequently.**  
  `pkg` safely deactivates an unrelated active env before activating the target.

- **Where is my env?**  
  Envs live under `~/.venvs/<project>`. Print the current setting with `uvp`.

## Nuke

- **mac only by default.**  
  The helper stubs out on non‑mac platforms to avoid surprising launches.

## Prompt/Colors

- **`%f` shows up in messages.**  
  Use `print -P` when you include `%F{..}`/`%f` prompt escapes in messages. Example:
  ```zsh
  print -P "→ %F{cyan}name%f active %F{8}[${PWD}]%f"
  ```
