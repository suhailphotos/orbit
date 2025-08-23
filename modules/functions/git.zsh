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
  git -C "$repo" fetch -q origin || { echo "  fetch failed; skipping"; return 0; }

  # Is 'main' checked out in any worktree? If so, fast-forward there.
  local main_wt
  main_wt="$(git -C "$repo" worktree list --porcelain | awk '
    $1=="worktree"{wt=$2}
    $1=="branch" && $2=="refs/heads/main"{print wt}
  ')"

  if [[ -n "$main_wt" ]]; then
    # main is checked out somewhere (maybe $repo itself) → do an in-place FF merge
    if git -C "$main_wt" merge --ff-only origin/main; then
      echo "  main fast-forwarded in worktree: $main_wt"
    else
      echo "  main already up-to-date (or cannot fast-forward)."
    fi
  else
    # main is not checked out in any worktree → safe to update the ref without switching branches
    if git -C "$repo" show-ref --verify --quiet refs/heads/main; then
      git -C "$repo" update-ref -m "ff main -> origin/main" \
        refs/heads/main refs/remotes/origin/main \
        && echo "  main advanced to origin/main (ref updated)."
    else
      # create the branch if it doesn't exist
      git -C "$repo" branch main origin/main && echo "  main created from origin/main."
    fi
  fi
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
