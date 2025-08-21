# Ensure a UTF-8 login shell (no LC_ALL). Run this late so we converge the pair.
# Strategy:
#   - If LC_CTYPE is already UTF-8, keep it and sync LANG if needed.
#   - Else if LANG is UTF-8, use that and set LC_CTYPE to match.
#   - Else fall back to C.UTF-8 (present on Ubuntu/Debian by default).

if [[ -o interactive ]]; then
  local desired=""
  if [[ ${LC_CTYPE-} == *UTF-8* ]]; then
    desired="$LC_CTYPE"
  elif [[ ${LANG-} == *UTF-8* ]]; then
    desired="$LANG"
  else
    desired="C.UTF-8"
  fi

  # Sync both; don’t touch LC_ALL.
  [[ ${LC_CTYPE-} == "$desired" ]] || export LC_CTYPE="$desired"
  # If LANG is empty or non-UTF-8, align it too.
  if [[ ${LANG-} != *UTF-8* || ${LANG-} != "$desired" ]]; then
    export LANG="$desired"
  fi
  unset desired
fi
