#!/usr/bin/env bash

# Commit & push helper
lazygit() {
  if [ -z "$1" ]; then
    echo "Usage: lazygit <commit message> [branch]"
    return 1
  fi

  local message="$1"
  local branch="${2:-main}"

  git add .
  git commit -m "$message"
  git push origin "$branch"
}

# Merge source into target, with a commit message, no editor
merge_branch() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: merge_branch <source-branch> <target-branch>"
    return 1
  fi

  local src="$1"
  local tgt="$2"

  git fetch origin
  git checkout "$tgt"
  git pull origin "$tgt"
  git merge --no-ff "$src" -m "Merge branch '$src' into $tgt"
  git push origin "$tgt"
}
