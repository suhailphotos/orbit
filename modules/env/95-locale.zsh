# Ensure a UTF-8 login shell (no LC_ALL). Run this late so we converge the pair.
# Strategy:
#   - If LC_CTYPE is already UTF-8, keep it and sync LANG if needed.
#   - Else if LANG is UTF-8, use that and set LC_CTYPE to match.
#   - Else fall back to C.UTF-8 (present on Ubuntu/Debian by default).

if [[ -o interactive ]]; then
  local desired=""

  # Prefer whatever UTF-8 you already have.
  if [[ ${LC_CTYPE-} == *[Uu][Tt][Ff]-8* ]]; then
    desired="$LC_CTYPE"
  elif [[ ${LANG-} == *[Uu][Tt][Ff]-8* ]]; then
    desired="$LANG"
  else
    # Safe default on modern Ubuntu/Debian (glibc provides C.UTF-8)
    desired="${ORBIT_DEFAULT_LOCALE:-C.UTF-8}"
  fi

  # Apply without fighting user overrides
  [[ ${LC_CTYPE-} == "$desired" ]] || export LC_CTYPE="$desired"
  if [[ -z ${LANG-} || ${LANG-} != "$desired" ]]; then
    export LANG="$desired"
  fi

  # Optional ultra-rare fallback:
  # If this host doesn't have C.UTF-8, try en_US.UTF-8 once.
  # Runs only when neither LANG/LC_CTYPE were UTF-8.
  # if [[ $desired == C.UTF-8 ]] && ! locale -a 2>/dev/null | grep -qi '^c\.utf-8$'; then
  #   if locale -a 2>/dev/null | grep -qi '^en_US\.utf-8$'; then
  #     export LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8
  #   fi
  # fi
fi


