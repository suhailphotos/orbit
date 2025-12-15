# Commit + push
git_commit_push() {
  [ -z "${1:-}" ] && { echo "Usage: git_commit_push <message> [branch]"; return 1; }

  # Default branch = currently checked out branch
  current_branch="$(
    command git symbolic-ref --short HEAD 2>/dev/null \
      || command git rev-parse --abbrev-ref HEAD 2>/dev/null
  )"

  [ -z "$current_branch" ] && { echo "Could not determine current branch." >&2; return 1; }

  branch="${2:-$current_branch}"

  command git add . || return 1
  command git commit -m "$1" || return 1
  command git push origin "$branch"
}

# Fast merge with message
merge_branch() {
  [[ -z $1 || -z $2 ]] && { echo "Usage: merge_branch <src> <tgt>"; return 1; }
  git fetch origin
  git checkout "$2" && git pull origin "$2"
  git merge --no-ff "$1" -m "Merge branch '$1' into $2"
  git push origin "$2"
}

# Push and copy GitHub blob URL for a file at HEAD
git_blob_push() {
  if [[ -z "$1" ]]; then
    echo "Usage: git_blob_push <path/to/file> [remote] [branch]" >&2
    return 1
  fi

  local file="$1"
  local remote="${2:-origin}"
  local branch
  branch="${3:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null)}"

  if [[ -z "$branch" ]]; then
    echo "Could not determine current branch." >&2
    return 1
  fi

  # Sanity check: file exists
  if [[ ! -e "$file" ]]; then
    echo "File not found: $file" >&2
    return 1
  fi

  # 1) Push
  command git push "$remote" "$branch" || return 1

  # 2) Resolve remote URL (handle SSH + HTTPS)
  local remote_url
  remote_url="$(command git remote get-url "$remote")" || return 1
  remote_url="${remote_url%.git}"

  if [[ "$remote_url" == git@*:*/* ]]; then
    # git@github.com:user/repo → https://github.com/user/repo
    local hostpath="${remote_url#git@}"      # github.com:user/repo
    local host="${hostpath%%:*}"             # github.com
    local path="${hostpath#*:}"              # user/repo
    remote_url="https://$host/$path"
  fi

  # 3) Commit hash
  local commit
  commit="$(command git rev-parse HEAD)" || return 1

  # 4) Path relative to repo root
  local rel root
  rel="$(command git ls-files --full-name "$file" 2>/dev/null || true)"
  if [[ -z "$rel" ]]; then
    root="$(command git rev-parse --show-toplevel)" || return 1
    rel="${file#$root/}"
  fi

  local url="${remote_url}/blob/${commit}/${rel}"

  echo "Blob URL:"
  echo "  $url"

  # 5) Copy to clipboard (mac pbcopy or Orbit's Linux pbcopy shim)
  if command -v pbcopy >/dev/null 2>&1; then
    printf '%s' "$url" | pbcopy
    echo "(copied to clipboard)"
  else
    echo "(pbcopy not found; URL not copied automatically)" >&2
  fi
}
