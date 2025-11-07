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

# Push and copy GitHub blob URL for a file at HEAD
git_blob_push() {
  emulate -L zsh
  setopt pipefail

  if [[ -z "$1" ]]; then
    echo "Usage: git_blob_push <path/to/file> [remote] [branch]" >&2
    return 1
  fi

  local file="$1"; shift
  local remote="${1:-origin}"
  # default branch = current branch
  local branch="${2:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null)}"

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
  git push "$remote" "$branch" || return 1

  # 2) Resolve remote URL (handle SSH + HTTPS)
  local remote_url
  remote_url="$(git remote get-url "$remote")" || return 1
  remote_url="${remote_url%.git}"

  if [[ "$remote_url" == git@*:*/* ]]; then
    # git@github.com:user/repo  →  https://github.com/user/repo
    local hostpath="${remote_url#git@}"      # github.com:user/repo
    local host="${hostpath%%:*}"             # github.com
    local path="${hostpath#*:}"              # user/repo
    remote_url="https://$host/$path"
  fi

  # 3) Commit hash
  local commit
  commit="$(git rev-parse HEAD)" || return 1

  # 4) Path relative to repo root
  local rel
  rel="$(git ls-files --full-name "$file" 2>/dev/null || true)"
  if [[ -z "$rel" ]]; then
    # fallback: strip repo root prefix if ls-files didn't know it
    local root
    root="$(git rev-parse --show-toplevel)" || return 1
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
    echo "(pbcopy not found; install or use Orbit's clipboard helpers)" >&2
  fi
}
