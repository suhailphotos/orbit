# helpers/ghostty_xterm.sh
#!/usr/bin/env bash
set -euo pipefail

# Resolve the repo root relative to this script
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$REPO/assets/terminfo"

# Prefer Homebrew ncurses 'infocmp' (macOS /usr/bin/infocmp can be too old)
if command -v /opt/homebrew/opt/ncurses/bin/infocmp >/dev/null 2>&1; then
  INFOCMP="/opt/homebrew/opt/ncurses/bin/infocmp"
elif command -v /usr/local/opt/ncurses/bin/infocmp >/dev/null 2>&1; then
  INFOCMP="/usr/local/opt/ncurses/bin/infocmp"
else
  INFOCMP="$(command -v infocmp || true)"
fi

DB="/Applications/Ghostty.app/Contents/Resources/terminfo"

if [[ -n "$INFOCMP" ]] && "$INFOCMP" -x xterm-ghostty >/dev/null 2>&1; then
  "$INFOCMP" -x xterm-ghostty > "$REPO/assets/terminfo/ghostty.ti"
elif [[ -d "$DB" ]] && [[ -n "$INFOCMP" ]]; then
  "$INFOCMP" -x -A "$DB" xterm-ghostty > "$REPO/assets/terminfo/ghostty.ti"
else
  echo "Couldn't locate a working infocmp/terminfo for xterm-ghostty.
Try: brew install ncurses, then re-run this command from inside a Ghostty session." >&2
  exit 1
fi

git -C "$REPO" add assets/terminfo/ghostty.ti
git -C "$REPO" commit -m "terminfo: add/update ghostty.ti so hosts can bootstrap without Ghostty" || true
git -C "$REPO" push
echo "Saved assets/terminfo/ghostty.ti to Orbit and pushed."
