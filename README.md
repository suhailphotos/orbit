# Orbit

A lightweight, modular shell bootstrap for macOS and Linux that keeps your shell environment, paths, secrets, aliases, and helper functions **in one repo** and **in sync across machines**. Orbit is designed to be:
- **Layered:** global → platform → machine scopes.
- **Deterministic:** ordered file loading with predictable overrides.
- **Git-native:** pull latest on every new shell (silent & disowned).
- **Tool-friendly:** plays nicely with Helix/Ansible installers.

> mac-only: Houdini and Nuke helpers are enabled on macOS. Linux boxes don’t load them.
> host-specific: CUDA/Conda etc. are loaded only on named hosts (e.g. `nimbus`).

---

## Quick Start

1. **Install Orbit**
   ```bash
   # from the orbit repo:
   ./install.sh --zshrc yes   # writes a clean ~/.zshrc from template
   # or: ./install.sh --zshrc no  # skip writing ~/.zshrc if managed by Ansible/Helix
   ```

2. **Open a new terminal** (or `source ~/.zshrc`). Orbit will:
   - Load secrets from `secrets/.env` or via 1Password (`secrets/op_token`).
   - Load **env** in order: `modules/env/*.zsh`
   - Load **aliases** in order: `modules/aliases/*.zsh`
   - Load **functions** from: `modules/functions/*.zsh`
   - Perform a **silent fast‑forward update** from Git in the background.

3. **Set up secrets** (optional but recommended):
   - Create `secrets/.env` and/or drop a 1Password token in `secrets/op_token`.
   - You can reference `op://vault/item/field` in `.env` values; Orbit will read those via `op`.

---

## Repository Layout

```
orbit/
├─ core/
│  ├─ bootstrap.zsh          # main loader: secrets → env → aliases → functions → completions
│  ├─ detect_platform.zsh    # sets ORBIT_PLATFORM (mac/linux/wsl/other) and ORBIT_HOST
│  ├─ path_helpers.zsh       # path helpers + .env loader w/ 1Password support
│  └─ secrets.zsh            # secrets loading (secrets/.env and/or 1Password)
├─ modules/
│  ├─ env/                   # environment variables, ordered & layered
│  │  ├─ 00-global.zsh       # global defaults (apply everywhere)
│  │  ├─ 10-mac.zsh          # mac-only env
│  │  ├─ 10-linux.zsh        # linux-only env (minimal by default)
│  │  ├─ 20-paths.zsh        # path-like globals with platform-aware values
│  │  ├─ 30-houdini.zsh      # mac-only Houdini prefs auto-detection
│  │  ├─ 40-nebula_ai.zsh    # NEBULA_AI_* paths (platform-aware)
│  │  └─ 90-host-*.zsh       # host-specific (e.g., 90-host-nimbus.zsh)
│  ├─ aliases/               # aliases, ordered like env (global → platform → host)
│  │  ├─ 00-global.zsh
│  │  ├─ 10-mac.zsh
│  │  ├─ 10-linux.zsh
│  │  └─ 90-host-*.zsh
│  └─ functions/             # shell functions grouped by topic
│     ├─ git.zsh             # lazygit, merge_branch, etc.
│     ├─ venv.zsh            # env activation & publish helpers
│     ├─ houdini.zsh         # mac-only Houdini helpers (no-op elsewhere)
│     ├─ nuke.zsh            # mac-only Nuke helpers (no-op elsewhere)
│     ├─ notion.zsh          # Notion helpers
│     └─ external.zsh        # optional: sources legacy API scripts if present
├─ secrets/
│  ├─ .env.template          # example of keys you might want
│  └─ op_token               # optional: 1Password service account token
├─ templates/
│  ├─ zshrc.mac              # zshrc template (mac)
│  └─ zshrc.linux            # zshrc template (linux)
└─ install.sh                # Bash installer: clone/update and optionally write ~/.zshrc
```

### Load Order (very important)

1. `core/secrets.zsh` → load `secrets/.env` and possibly `op://...` values
2. `modules/env/*.zsh` (sorted): environment variables
3. `modules/aliases/*.zsh` (sorted): aliases (later files override earlier ones)
4. `modules/functions/*.zsh` (unsorted glob, but keep per-file guards)
5. Completions: lazy-loaded on first prompt

> **Ordering rule**: higher numbers (e.g., `90-host-*.zsh`) load **after** lower ones, so host files override platform files which override globals.

---

## Scopes: Global vs Platform vs Machine

Orbit is explicitly layered:

### 1) Global (applies everywhere)
- Files: `modules/env/00-global.zsh`, `modules/aliases/00-global.zsh`
- Examples:
  ```zsh
  # 00-global.zsh
  export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
  orbit_prepend_path "$HOME/.local/bin"   # pipx etc
  ```
  ```zsh
  # 00-global.zsh (aliases)
  alias lg='lazygit'     # available everywhere
  alias gs='git status'
  ```

### 2) Platform (mac or linux)
- Files: `modules/env/10-mac.zsh`, `modules/env/10-linux.zsh`, and matching alias files.
- Examples:
  ```zsh
  # 10-mac.zsh
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d "$PYENV_ROOT/bin" ]] && orbit_prepend_path "$PYENV_ROOT/bin"
  command -v pyenv >/dev/null && eval "$(pyenv init -)"
  ```
  ```zsh
  # 10-linux.zsh
  # Keep minimal; host-specific CUDA/Conda go in 90-host-<name>.zsh
  : # no-op for now
  ```
  ```zsh
  # 10-mac.zsh (aliases)
  alias o='open .'
  ```
  ```zsh
  # 10-linux.zsh (aliases)
  alias o='xdg-open .'
  ```

### 3) Machine (host-specific)
- Files: `modules/env/90-host-<hostname>.zsh`, `modules/aliases/90-host-<hostname>.zsh`
- Examples (`90-host-nimbus.zsh`):
  ```zsh
  # env
  export ORBIT_USE_CONDA=1
  export CUDA_HOME="/usr/local/cuda"
  orbit_prepend_path "$CUDA_HOME/bin"
  export LD_LIBRARY_PATH="$CUDA_HOME/lib64:${LD_LIBRARY_PATH}"
  # conda hook here ...
  ```
  ```zsh
  # aliases
  alias nvidia='nvidia-smi'
  ```

> **Tip:** your hostname is available as `ORBIT_HOST` (set at bootstrap). Make a file named accordingly, e.g., `90-host-nimbus.zsh` to scope settings *only* to that box.

---

## Global Paths (platform-aware)

Many global variables have platform-specific values, but are exported for **all** machines in `modules/env/20-paths.zsh`:
- `DROPBOX`, `MATRIX`, `DOCKER`, `DATALIB`, `ML4VFX`, `OBSIDIAN`
- `NEBULA_AI_ROOT` and `NEBULA_AI_*` (from `modules/env/30-nebula_ai.zsh`)

This ensures code can always reference the same variable name regardless of OS.

---

## Houdini & Nuke (mac-only)

- `modules/functions/houdini.zsh`: defines `houdiniUtils` (mac only)
  - `houdiniUtils` → prefs + Poetry venv
  - `houdiniUtils -e [20.5.584]` → also sources SideFX `houdini_setup`
  - `houdiniUtils patchenv` → appends your Poetry site-packages path to `houdini.env`
  - `houdiniUtils vscode FILE` → open temp file in VS Code
- `modules/functions/nuke.zsh`: defines `nukeUtils` (mac only)
  - `nukeUtils -e` → venv + `NUKE_PATH`
  - `nukeUtils launch` → attempts to open the Nuke app

On Linux, these functions are harmless stubs that print “macOS only.”

---

## Secrets

Orbit loads secrets **first**, so later files can reference them.

1. Create `secrets/.env` (git-ignored):
   ```ini
   # Example
   PREFECT_API_URL=http://10.81.29.44:4200/api
   # Or fetch via 1Password at runtime:
   CLOUDFLARE_API_TOKEN=op://Personal/Cloudflare API/credential
   ```

2. (Optional) Put a 1Password service account token in `secrets/op_token`:
   - Orbit will export `OP_SERVICE_ACCOUNT_TOKEN` and read any `op://...` entries found in `.env` via `op read`.

---

## How to add: environment variable

Pick a scope and add to the right file:

- **Global:** `modules/env/00-global.zsh` (generic, non-path) or `modules/env/20-paths.zsh` (path-like)
  ```zsh
  # 00-global.zsh
  export MY_API_STAGE="dev"
  ```

- **Platform:** `modules/env/10-mac.zsh` or `modules/env/10-linux.zsh`
  ```zsh
  # 10-mac.zsh
  export DOCKER_DESKTOP=true
  ```

- **Machine:** `modules/env/90-host-nimbus.zsh`
  ```zsh
  export BIGGPU=1
  ```

Then open a new shell or `source "$ORBIT_HOME/core/bootstrap.zsh"` to apply.

---

## How to add: alias

Aliases are now scoped exactly like env vars. Use the corresponding alias file:

- **Global:** `modules/aliases/00-global.zsh`
  ```zsh
  alias l='ls -lah'
  alias rg='ripgrep --hidden --glob !.git'
  ```

- **Platform:** `modules/aliases/10-mac.zsh` or `modules/aliases/10-linux.zsh`
  ```zsh
  # 10-mac.zsh
  alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
  ```
  ```zsh
  # 10-linux.zsh
  alias flushdns='sudo systemd-resolve --flush-caches'
  ```

- **Machine:** `modules/aliases/90-host-nimbus.zsh`
  ```zsh
  alias gpustats='watch -n1 nvidia-smi'
  ```

> **Override rule:** later files win. Put “default” aliases in `00-global.zsh`, tweak or override in platform/host files.

---

## How to add: function

Create or edit a file under `modules/functions/` (group by topic). Use guards where appropriate:

```zsh
# modules/functions/docker.zsh
# mac-only example
[[ $ORBIT_PLATFORM == mac ]] || return

dkprune() {
  docker system prune -af --volumes
}
```

Linux/mac variants can live in the same file (with platform guards) or separate files; either is fine.

> Functions don’t have a numeric load order today—keep them self-contained and guard with `[[ $ORBIT_PLATFORM == mac ]]` or host checks when needed.

---

## Updating aliases to support scopes

Orbit now sources **all** alias files in order. Make sure your `core/bootstrap.zsh` has:

```zsh
# 3. Aliases and functions
for f in $_ORBIT_DIR/modules/aliases/*.zsh(.N); do source "$f"; done
for f in $_ORBIT_DIR/modules/functions/*.zsh(.N); do source "$f"; done
```

And create these files (examples included):

```zsh
# modules/aliases/00-global.zsh
alias cliUtils='cd $DROPBOX/matrix/shellscripts'
alias houUserPref='cd $HOUDINI_USER_PREF_DIR'
alias vex='cd $HOUDINI_USER_PREF_DIR/vex'
alias lg='lazygit'
alias gs='git status'
```

```zsh
# modules/aliases/10-mac.zsh
[[ $ORBIT_PLATFORM == mac ]] || return
alias o='open .'
```

```zsh
# modules/aliases/10-linux.zsh
[[ $ORBIT_PLATFORM == linux ]] || return
alias o='xdg-open .'
```

```zsh
# modules/aliases/90-host-nimbus.zsh
[[ $ORBIT_HOST == nimbus ]] || return
alias nvidia='nvidia-smi'
alias gpustats='watch -n1 nvidia-smi'
```

> Add more host files as needed: `90-host-<your-host>.zsh`

---

## Installation & Updates

### First-time install
```bash
# from the orbit repo directory
./install.sh --zshrc yes
# or set custom location/remote:
ORBIT_HOME="$HOME/.orbit" \
ORBIT_REMOTE="git@github.com:suhailphotos/orbit.git" \
ORBIT_BRANCH="main" \
./install.sh --zshrc yes
```

The installed `~/.zshrc` will:
- Clone Orbit if missing
- On every new shell, **silently** fetch & fast‑forward merge the default branch in the background
- Source `core/bootstrap.zsh`

### Making changes and pushing to GitHub

1. Edit files under `orbit/` locally (env/aliases/functions/templates).
2. Test in your current shell:
   ```zsh
   source "$ORBIT_HOME/core/bootstrap.zsh"
   ```
3. Commit & push:
   ```zsh
   cd "$ORBIT_HOME"
   git checkout -b feature/my-change   # optional
   git add .
   git commit -m "Describe your change"
   git push origin HEAD
   # merge PR or push directly to main if that's your workflow
   ```
4. **Propagation:** Each machine picks up your change on the **next shell startup** via the disowned background update.
   - Want it now? Run:
     ```zsh
     git -C "$ORBIT_HOME" fetch --quiet \
       && git -C "$ORBIT_HOME" merge --ff-only "origin/${ORBIT_BRANCH:-main}" --quiet
     source "$ORBIT_HOME/core/bootstrap.zsh"
     ```

### If a machine has local edits
The ff-only merge will do nothing if there’s divergence.
- To discard local edits and match remote:
  ```zsh
  git -C "$ORBIT_HOME" fetch --quiet
  git -C "$ORBIT_HOME" reset --hard "origin/${ORBIT_BRANCH:-main}"
  ```
- Or rebase your local changes and push them.

---

## Ansible / Helix Integration

- Let **Helix** install apps (zsh, oh-my-zsh, p10k, brew/apt, poetry/pyenv).
- Use **Ansible** to clone Orbit and render zshrc (or call `install.sh --zshrc yes`).
- Host-specific config goes into `modules/env/90-host-*.zsh` and `modules/aliases/90-host-*.zsh`.
- Keep zshrc templates in `templates/` so both **manual install** and **Ansible templates** use the same source of truth.

Example Ansible task to render zshrc:
```yaml
- name: Render zshrc from Orbit
  template:
    src: "{{ ansible_env.HOME }}/.orbit/templates/zshrc.{{ 'mac' if ansible_system == 'Darwin' else 'linux' }}"
    dest: "{{ ansible_env.HOME }}/.zshrc"
  vars:
    ORBIT_HOME: "{{ ansible_env.HOME }}/.orbit"
    ORBIT_REMOTE: "https://github.com/suhailphotos/orbit.git"
    ORBIT_BRANCH: "main"
```

---

## Conventions & Tips

- **Numbered files** set order; later numbers win (use `00-`, `10-`, `20-`, … `90-`).
- Keep **functions** focused: one topic per file, guard with `[[ $ORBIT_PLATFORM == mac ]]` / host checks as needed.
- Prefer **exports** in `env/` only; avoid exporting in function files.
- Use `orbit_prepend_path "/some/path"` to avoid duplicates in `$PATH`.
- Keep secrets out of Git; use `secrets/.env` and `op://` entries.

---

## Troubleshooting

- **Something prints before prompt (p10k warning):** Ensure background git update uses `&!` and redirects to `/dev/null` (already in templates).
- **Houdini not found on mac:** verify install under `/Applications/Houdini/` and versions match `Houdini20.x`. Adjust `houdini.zsh` if SideFX layout changes.
- **Linux box loading CUDA/Conda everywhere:** move those to `modules/env/90-host-<hostname>.zsh` so they’re host-specific.
- **Aliases not applying:** check ordering—host files override platform which override global. Confirm your new file matches the expected pattern and is executable/readable.

---

## License

MIT

