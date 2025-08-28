#!/usr/bin/env bash
set -euo pipefail

# Defaults (overridable via env or flags)
ORBIT_HOME="${ORBIT_HOME:-$HOME/.orbit}"
ORBIT_REMOTE="${ORBIT_REMOTE:-https://github.com/suhailphotos/orbit.git}"
ORBIT_BRANCH="${ORBIT_BRANCH:-main}"
WRITE_ZSHRC=ask     # ask | yes | no
PLATFORM=""         # mac | linux | auto

usage() {
  cat <<EOF
Orbit installer

Usage:
  ./install.sh [options]

Options:
  --home PATH           Set install directory (default: $ORBIT_HOME)
  --remote URL          Git remote (default: $ORBIT_REMOTE)
  --branch NAME         Git branch (default: $ORBIT_BRANCH)
  --zshrc yes|no|ask    Write ~/.zshrc from template (default: ask)
  --platform mac|linux  Override platform detection (default: auto)
  --force               Force overwrite of existing ~/.zshrc when --zshrc yes
  -h, --help            Show this help

Notes:
- This script only installs/updates Orbit and (optionally) writes ~/.zshrc.
- Apps like oh-my-zsh, Powerlevel10k, Homebrew, Conda, CUDA, etc. are NOT installed here.
  Use your Helix/Ansible bootstrap for that.
EOF
}

FORCE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --home)     ORBIT_HOME="$2"; shift 2;;
    --remote)   ORBIT_REMOTE="$2"; shift 2;;
    --branch)   ORBIT_BRANCH="$2"; shift 2;;
    --zshrc)    WRITE_ZSHRC="$2"; shift 2;;
    --platform) PLATFORM="$2"; shift 2;;
    --force)    FORCE=1; shift;;
    -h|--help)  usage; exit 0;;
    *) echo "Unknown option: $1" >&2; usage; exit 1;;
  esac
done

detect_platform() {
  if [[ -n "$PLATFORM" ]]; then
    echo "$PLATFORM"
    return
  fi
  case "$(uname -s)" in
    Darwin) echo mac ;;
    Linux)  echo linux ;;
    *)      echo other ;;
  esac
}

ensure_git() {
  if ! command -v git >/dev/null 2>&1; then
    echo "Error: git is required. Install git first (brew/apt/etc.) and retry." >&2
    exit 1
  fi
}

install_or_update_orbit() {
  mkdir -p "$(dirname "$ORBIT_HOME")"
  if [[ -d "$ORBIT_HOME/.git" ]]; then
    echo "Updating Orbit in $ORBIT_HOME..."
    git -C "$ORBIT_HOME" fetch --quiet
    git -C "$ORBIT_HOME" checkout "$ORBIT_BRANCH" --quiet
    git -C "$ORBIT_HOME" merge --ff-only "origin/$ORBIT_BRANCH" --quiet || true
  else
    echo "Cloning Orbit into $ORBIT_HOME..."
    git clone --depth 1 --branch "$ORBIT_BRANCH" --quiet "$ORBIT_REMOTE" "$ORBIT_HOME"
  fi
  [[ -f "$ORBIT_HOME/core/bootstrap.zsh" ]] || {
    echo "Error: bootstrap missing; clone may have failed." >&2
    exit 1
  }
}

write_zshrc() {
  local platform="$1"
  local zshrc="$HOME/.zshrc"
  local template=""

  case "$platform" in
    mac)   template="$ORBIT_HOME/templates/zshrc.mac" ;;
    linux) template="$ORBIT_HOME/templates/zshrc.linux" ;;
    *)     echo "Skipping .zshrc: unsupported platform '$platform'." ; return 0 ;;
  esac

  if [[ "$WRITE_ZSHRC" == "no" ]]; then
    echo "Skipping .zshrc (per --zshrc no)."
    return 0
  fi

  if [[ -f "$zshrc" && "$WRITE_ZSHRC" == "ask" && $FORCE -eq 0 ]]; then
    read -r -p "~/.zshrc exists. Overwrite with Orbit template? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || { echo "Keeping existing ~/.zshrc"; return 0; }
  fi

  if [[ -f "$zshrc" && $FORCE -eq 0 && "$WRITE_ZSHRC" != "yes" ]]; then
    # Default to ask; if non-interactive, keep existing
    if [[ -t 0 ]]; then : ; else
      echo "Non-interactive and ~/.zshrc exists; keeping existing."
      return 0
    fi
  fi

  # Fill placeholders and write
  sed \
    -e "s|{{ORBIT_HOME}}|$ORBIT_HOME|g" \
    -e "s|{{ORBIT_REMOTE}}|$ORBIT_REMOTE|g" \
    -e "s|{{ORBIT_BRANCH}}|$ORBIT_BRANCH|g" \
    "$template" > "$zshrc"

  echo "Wrote $zshrc from $template"
}

summary() {
  cat <<EOF

✅ Orbit installed at: $ORBIT_HOME
   Remote: $ORBIT_REMOTE
   Branch: $ORBIT_BRANCH

- Open a new terminal, or 'source ~/.zshrc' to load Orbit.
- Configure secrets in: $ORBIT_HOME/secrets/.env (or add a 1Password token to $ORBIT_HOME/secrets/op_token)
- Host-specific env (like CUDA/Conda on nimbus): $ORBIT_HOME/modules/env/90-host-nimbus.zsh

EOF
}

main() {
  ensure_git
  local platform; platform="$(detect_platform)"
  install_or_update_orbit
  write_zshrc "$platform"
  summary
}

main "$@"
