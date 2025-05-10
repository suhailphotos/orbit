#!/usr/bin/env bash

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

merge_branch() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: merge_branch <source-branch> <target-branch>"
    return 1
  fi
  git fetch origin
  git checkout "$2"
  git pull origin "$2"
  git merge --no-ff "$1"
  git push origin "$2"
}
