# core/profile.zsh — portable micro-profiler (Nimbus-safe)

# Best-effort light deps
zmodload zsh/datetime 2>/dev/null || true
zmodload zsh/zprof     2>/dev/null || true

# Log file
: ${ORBIT_PROFILE_LOG:="${XDG_CACHE_HOME:-$HOME/.cache}/orbit/profile.$$.log"}
mkdir -p "${ORBIT_PROFILE_LOG:h}" 2>/dev/null || true

# Monotonic-ish "now" that works with or without EPOCHREALTIME
__oprof_now() { print -r -- "${EPOCHREALTIME:-$EPOCHSECONDS}"; }

typeset -gF _oprof_t0=$(__oprof_now)

# One line writer: HH:MM:SS \t seconds \t message
_oprof_write() {
  local ts; ts="$(print -P "%D{%H:%M:%S}")"
  printf '%s\t%0.3f\t%s\n' "$ts" "$1" "$2" >>"$ORBIT_PROFILE_LOG" 2>/dev/null
}

# Time every "source" call (including module loops)
source() {
  local f="$1"; shift || true
  local s=$(__oprof_now)
  builtin . "$f" "$@"
  local d; (( d = $(__oprof_now) - s ))
  _oprof_write "$d" "source $f"
}

# Ad-hoc timers
orbit_time() {
  local label="$1"; shift
  local s=$(__oprof_now); "$@"; local rc=$?
  local d; (( d = $(__oprof_now) - s ))
  _oprof_write "$d" "RUN  $label (rc=$rc)"
  return $rc
}
orbit_mark() {
  local label="$*"
  local d; (( d = $(__oprof_now) - _oprof_t0 ))
  _oprof_write "$d" "MARK $label"
}

# Summary + cleanup
_orbit_profile_done() {
  local total; (( total = $(__oprof_now) - _oprof_t0 ))
  _oprof_write "$total" "TOTAL orbit bootstrap"
  if typeset -f zprof >/dev/null 2>&1; then
    { echo; echo '— zprof (functions) —'; zprof; } >>"$ORBIT_PROFILE_LOG" 2>&1
  fi
  unfunction source 2>/dev/null || true
  unfunction orbit_time orbit_mark _orbit_profile_done 2>/dev/null || true
}
