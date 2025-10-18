# core/profile.zsh — opt-in micro-profiler for Orbit init (gated by ORBIT_PROFILE=1)

# lightweight deps
zmodload zsh/datetime 2>/dev/null || true
zmodload zsh/zprof     2>/dev/null || true

# where logs go
: ${ORBIT_PROFILE_LOG:="${XDG_CACHE_HOME:-$HOME/.cache}/orbit/profile.$$.log"}
mkdir -p "${ORBIT_PROFILE_LOG:h}" 2>/dev/null || true

typeset -gF _oprof_t0=${EPOCHREALTIME:-0.0}

_oprof_write() { printf '%(%H:%M:%S)T\t%0.3f\t%s\n' -1 "$1" "$2" >>"$ORBIT_PROFILE_LOG"; }

# time every "source" (including modules/env/* loops and prompts)
source() {
  local f="$1"; shift || true
  local s=${EPOCHREALTIME:-0.0}
  builtin . "$f" "$@"      # call the real builtin
  local d; (( d = ${EPOCHREALTIME:-0.0} - s ))
  _oprof_write "$d" "source $f"
}

# ad-hoc timers for explicit hotspots if you want to sprinkle them in
orbit_time() {
  local label="$1"; shift
  local s=${EPOCHREALTIME:-0.0}
  "$@"; local rc=$?
  local d; (( d = ${EPOCHREALTIME:-0.0} - s ))
  _oprof_write "$d" "RUN  $label (rc=$rc)"
  return $rc
}
orbit_mark() {
  local label="$*"
  local d; (( d = ${EPOCHREALTIME:-0.0} - _oprof_t0 ))
  _oprof_write "$d" "MARK $label"
}

# print summary and restore builtins
_orbit_profile_done() {
  local total; (( total = ${EPOCHREALTIME:-0.0} - _oprof_t0 ))
  _oprof_write "$total" "TOTAL orbit bootstrap"
  { echo; echo '— zprof (functions) —'; zprof; } >>"$ORBIT_PROFILE_LOG" 2>&1
  unfunction source   2>/dev/null || true
  unfunction orbit_time orbit_mark _orbit_profile_done 2>/dev/null || true
}
