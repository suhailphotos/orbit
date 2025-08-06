# modules/functions/venv.zsh
# ------------------------------------------------------------------
# Orbit: Environment activation & publish helpers
# ------------------------------------------------------------------

# --- Helper to create env activation functions ---
_orbit_make_env() {
  local fname=$1         # function name exposed to user
  local project=$2       # folder under packages/
  local conda=$3         # conda env name (linux only)

  eval "
${fname}() {
  local root=\"\$DROPBOX/matrix/packages/${project}\"
  [[ -d \"\$root\" ]] || { echo \"Project not found: \$root\" >&2; return 1; }

  export PROJECT_ROOT=\"\$root\"
  [[ \"\$PWD\" == \"\$root\" ]] || cd \"\$root\"

  if [[ \$ORBIT_PLATFORM == mac ]]; then
    [[ -n \$VIRTUAL_ENV ]] || source \"\$(poetry env info --path)/bin/activate\"
  elif [[ \$ORBIT_PLATFORM == linux ]]; then
    [[ -n \$CONDA_PREFIX ]] || conda activate ${conda}
  fi
}"
}

# --- Helper to publish a Poetry project (auto-increments patch version) ---
_orbit_publish() {
  local project="$1"
  local root="$DROPBOX/matrix/packages/${project}"
  [[ -d "$root" ]] || { echo "Project not found: $root" >&2; return 1; }
  cd "$root" || return 1

  # Grab version from pyproject.toml
  local version_line current_version
  version_line=$(grep '^version' pyproject.toml | head -1)
  current_version=$(echo "$version_line" | sed -E 's/version = "([0-9]+\.[0-9]+\.[0-9]+)".*/\1/')
  IFS='.' read -r major minor patch <<< "$current_version"
  local new_patch=$((patch + 1))
  local new_version="${major}.${minor}.${new_patch}"

  echo "Incrementing version: $current_version -> $new_version"
  sed -i.bak -E "s#(version = \")$current_version(\".*)#\1$new_version\2#" pyproject.toml

  poetry publish --build

  cd - >/dev/null
}

# -------------------------
# Define the environments
# -------------------------
local orbit_projects=(
  usdUtils
  oauthManager
  pythonKitchen
  houdiniLab
  ocioTools
  helperScripts
  Incept
  pariVaha
  Lumiera
  Ledu
)

for project in "${orbit_projects[@]}"; do
  _orbit_make_env "$project" "$project" "$project"
  eval "
    publish_${project}() {
      _orbit_publish $project
    }
  "
done

