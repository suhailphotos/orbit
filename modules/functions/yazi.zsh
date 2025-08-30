# Only define if Yazi is present
if command -v yazi >/dev/null 2>&1; then
  # y  → run yazi and cd to the directory you end up in when quitting
  y() {
    local tmp
    tmp="$(mktemp -t 'yazi-cwd.XXXXXX')" || return
    yazi --cwd-file="$tmp" "$@"
    if [ -r "$tmp" ]; then
      local newcwd
      newcwd="$(cat -- "$tmp")"
      [ -n "$newcwd" ] && [ "$newcwd" != "$PWD" ] && cd -- "$newcwd"
      rm -f -- "$tmp"
    fi
  }

  # quick aliases that never break other machines
  alias yy='yazi'
  alias yya='yazi --chooser=append'   # example: multi-select mode (adjust to taste)
fi
