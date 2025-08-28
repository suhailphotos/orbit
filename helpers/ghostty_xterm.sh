# one-shot: export ghostty terminfo into Orbit and push it
REPO="${MATRIX:-$HOME/Library/CloudStorage/Dropbox/matrix}/orbit"
mkdir -p "$REPO/assets/terminfo"

# Prefer Homebrew ncurses 'infocmp' (old macOS /usr/bin/infocmp can be incompatible)
if command -v /opt/homebrew/opt/ncurses/bin/infocmp >/dev/null 2>&1; then
  INFOCMP="/opt/homebrew/opt/ncurses/bin/infocmp"
elif command -v /usr/local/opt/ncurses/bin/infocmp >/dev/null 2>&1; then
  INFOCMP="/usr/local/opt/ncurses/bin/infocmp"
else
  INFOCMP="$(command -v infocmp || true)"
fi

DB="/Applications/Ghostty.app/Contents/Resources/terminfo"

set -e
if [[ -n "$INFOCMP" ]] && "$INFOCMP" -x xterm-ghostty >/dev/null 2>&1; then
  "$INFOCMP" -x xterm-ghostty > "$REPO/assets/terminfo/ghostty.ti"
elif [[ -d "$DB" ]] && [[ -n "$INFOCMP" ]]; then
  # Use Ghostty’s bundled terminfo database as a source
  "$INFOCMP" -x -A "$DB" xterm-ghostty > "$REPO/assets/terminfo/ghostty.ti"
else
  echo "Couldn't locate a working infocmp/terminfo for xterm-ghostty.
Try: brew install ncurses, then re-run this command from inside a Ghostty session." >&2
  exit 1
fi

git -C "$REPO" add assets/terminfo/ghostty.ti
git -C "$REPO" commit -m "terminfo: add ghostty.ti so hosts can bootstrap without Ghostty"
git -C "$REPO" push
echo "✅ Saved assets/terminfo/ghostty.ti to Orbit and pushed."
