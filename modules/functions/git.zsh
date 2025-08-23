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

# Push ~/.config (worktree) to helix:config and fast-forward helix:main
configpush() {
  local repo=""
  if [[ -d "$MATRIX/helix/.git" ]]; then
    repo="$MATRIX/helix"
  elif [[ -d "$HOME/.helix/.git" ]]; then
    repo="$HOME/.helix"
  else
    echo "helix repo not found (looked in \$MATRIX/helix and ~/.helix)"; return 1
  fi

  local cfg="$HOME/.config"
  if ! git -C "$cfg" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "~/.config is not a git worktree"; return 1
  fi

  # default message includes host + timestamp
  local msg="${1:-"chore(config): update from ${ORBIT_HOST:-$(hostname -s)} $(date +'%Y-%m-%d %H:%M')"}"

  echo "→ Commit & push config worktree"
  git -C "$cfg" add -A
  if git -C "$cfg" diff --cached --quiet; then
    echo "  no changes to commit"
  else
    git -C "$cfg" commit -m "$msg"
  fi
  git -C "$cfg" push origin HEAD || return 1

  echo "→ Fast-forward helix:main in repo $repo"
  git -C "$repo" fetch origin
  # stay on whatever branch you're on; just advance main silently
  if git -C "$repo" show-ref --verify --quiet refs/heads/main; then
    git -C "$repo" branch --quiet --force main origin/main || true
  else
    git -C "$repo" checkout -q -b main origin/main || true
  fi

  echo "config pushed; main updated."
}

configpull() {
  local repo=""
  if   [[ -d "$MATRIX/helix/.git" ]]; then repo="$MATRIX/helix"
  elif [[ -d "$HOME/.helix/.git" ]]; then repo="$HOME/.helix"
  else echo "helix repo not found"; return 1; fi

  echo "→ Update config worktree"
  git -C "$HOME/.config" pull --ff-only || return 1

  echo "→ Update helix:main"
  git -C "$repo" fetch origin
  git -C "$repo" checkout -q main || true
  git -C "$repo" merge --ff-only origin/main || true

  echo "config + main updated."
}
