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
