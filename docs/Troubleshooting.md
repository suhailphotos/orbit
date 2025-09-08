# Troubleshooting

## Houdini

- **`hou use` says "Not inside a Poetry project".**  
  Run it from a directory that contains `pyproject.toml`, or set `HOU_PROJECT_ROOT=/abs/path`.

- **`hou import` fails with missing symbols on macOS.**  
  Make sure `houdini_setup` was successfully sourced by `hou import` (or run `hou env` first).

- **Houdini can’t see my module.**  
  Prefer a packages JSON (Tessera) or run `hou pkgshim` to append your venv’s `site-packages` to `PYTHONPATH` at runtime.

## `pkg` / Poetry

- **No venv yet.**  
  `pkg` runs `poetry install` automatically, then activates the new venv.

- **Switching projects frequently.**  
  `pkg` sources the target venv even if another is active. This is safe in practice; if you want to hard‑deactivate first, you can add a tiny helper to your environment:
  ```zsh
  _py_deactivate_if_needed() { command -v deactivate >/dev/null 2>&1 && deactivate || true; }
  ```
  And call it before activating inside your custom wrappers.

## Nuke

- **mac only by default.**  
  The helper stubs out on non‑mac platforms to avoid surprising launches.

## Prompt/Colors

- **`%f` shows up in messages.**  
  Use `print -P` when you include `%F{..}`/`%f` prompt escapes in messages. Example:
  ```zsh
  print -P "→ %F{cyan}name%f active %F{8}[${PWD}]%f"
  ```
