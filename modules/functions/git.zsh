# Commit + push
lazygit() {
  [[ -z $1 ]] && { echo "Usage: lazygit <message> [branch]"; return 1; }
  local branch="${2:-main}"
  git add .
  git commit -m "$1"
  git push origin "$branch"
}

# Fast merge with message
merge_branch() {
  [[ -z $1 || -z $2 ]] && { echo "Usage: merge_branch <src> <tgt>"; return 1; }
  git fetch origin
  git checkout "$2" && git pull origin "$2"
  git merge --no-ff "$1" -m "Merge branch '$1' into $2"
  git push origin "$2"
}

# ---- subtree settings -------------------------------------------------------
# Where the config subtree lives inside the helix mono-repo:
: ${ORBIT_HELIX_SUBTREE_PREFIX:=dotfiles/config/.config}

# Which branch backs your ~/.config worktree:
: ${ORBIT_CONFIG_BRANCH:=config}

# Resolve helix repo path (prefer $MATRIX/helix, fallback to ~/.helix)
_helix_repo_path() {
  if [[ -d "$MATRIX/helix/.git" ]]; then
    echo "$MATRIX/helix"
  elif [[ -d "$HOME/.helix/.git" ]]; then
    echo "$HOME/.helix"
  else
    return 1
  fi
}

# Require clean repo (no staged/unstaged changes)
_require_clean_repo() {
  local repo="$1"
  if ! git -C "$repo" diff --quiet || ! git -C "$repo" diff --cached --quiet; then
    echo "Repo at $repo has uncommitted changes. Commit/stash before continuing." >&2
    return 1
  fi
}

# ---- cpush: push ~/.config, then integrate into helix/main via subtree pull --
configpush() {
  local cfg="$HOME/.config"
  local repo; repo="$(_helix_repo_path)" || { echo "helix repo not found"; return 1; }
  local prefix="$ORBIT_HELIX_SUBTREE_PREFIX"
  local msg="${1:-"chore(config): update from ${ORBIT_HOST:-$(hostname -s)} $(date +'%Y-%m-%d %H:%M')"}"

  if ! git -C "$cfg" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "~/.config is not a git worktree"; return 1
  fi

  echo "→ Commit & push ~/.config → origin/${ORBIT_CONFIG_BRANCH}"
  git -C "$cfg" add -A
  if ! git -C "$cfg" diff --cached --quiet; then
    git -C "$cfg" commit -m "$msg" || return 1
  else
    echo "  no changes to commit"
  fi
  git -C "$cfg" push origin "HEAD:${ORBIT_CONFIG_BRANCH}" || return 1

  echo "→ Integrate into helix:main via subtree pull"
  _require_clean_repo "$repo" || return 1
  local cur; cur="$(git -C "$repo" rev-parse --abbrev-ref HEAD)"

  git -C "$repo" fetch -q origin || return 1
  git -C "$repo" checkout -q main || return 1
  git -C "$repo" pull --ff-only || return 1

  git -C "$repo" subtree pull \
    --prefix="$prefix" \
    origin "$ORBIT_CONFIG_BRANCH" \
    -m "subtree pull: sync .config from ${ORBIT_CONFIG_BRANCH}" || return 1

  # Optional: push updated main (comment out if you don't want this)
  # git -C "$repo" push origin main || true

  # go back to where you were if it wasn't main
  [[ "$cur" != "main" ]] && git -C "$repo" checkout -q "$cur" || true
  echo "✅ cpush complete."
}

# ---- cpull: refresh helix/main from origin/config, then update ~/.config -----
configpull() {
  local cfg="$HOME/.config"
  local repo; repo="$(_helix_repo_path)" || { echo "helix repo not found"; return 1; }
  local prefix="$ORBIT_HELIX_SUBTREE_PREFIX"

  echo "→ Update helix:main from origin and subtree pull origin/${ORBIT_CONFIG_BRANCH}"
  _require_clean_repo "$repo" || return 1
  local cur; cur="$(git -C "$repo" rev-parse --abbrev-ref HEAD)"

  git -C "$repo" fetch -q origin || return 1
  git -C "$repo" checkout -q main || return 1
  git -C "$repo" pull --ff-only || return 1

  git -C "$repo" subtree pull \
    --prefix="$prefix" \
    origin "$ORBIT_CONFIG_BRANCH" \
    -m "subtree pull: sync .config from ${ORBIT_CONFIG_BRANCH}" || return 1

  # Optional: push updated main
  # git -C "$repo" push origin main || true

  [[ "$cur" != "main" ]] && git -C "$repo" checkout -q "$cur" || true

  echo "→ Fast-forward ~/.config worktree to origin/${ORBIT_CONFIG_BRANCH}"
  if git -C "$cfg" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$cfg" fetch -q origin || return 1
    git -C "$cfg" pull --ff-only || return 1
  else
    echo "~/.config is not a git worktree; skipped." >&2
  fi
  echo "✅ cpull complete."
}
