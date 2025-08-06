# modules/functions/nuke.zsh
# ------------------------------------------------------------------
# Nuke utility: Poetry env, directory, and command cases (template)
# ------------------------------------------------------------------

nukeUtils() {
  local root="$DROPBOX/matrix/packages/nukeUtils"
  local nuke_version="15.0v4"  # Update as needed; placeholder
  local optional_command="$1"

  # -------- Helper: Activate env and cd if needed --------
  change_dir_activate() {
    if [[ "$PWD" != "$root" && -n "$VIRTUAL_ENV" ]]; then
      cd "$root" || return 1
    elif [[ "$PWD" != "$root" && -z "$VIRTUAL_ENV" ]]; then
      cd "$root" || return 1
      source "$(poetry env info --path)/bin/activate" || return 1
    fi
  }

  # -------- Placeholder: Nuke-specific envs or prefs --------
  # set_nuke_user_pref() {
  #   if [[ -z "$NUKE_USER_PREF_DIR" ]]; then
  #     export NUKE_USER_PREF_DIR="$HOME/Library/Preferences/Nuke/${nuke_version}"
  #   fi
  # }

  # set_env_vars() {
  #   export PYTHONPATH="..."
  #   export OTHER_NUKE_VARS="..."
  #   # Add more as needed
  # }

  # -------- Command Logic --------

  if [[ -n "$optional_command" ]]; then
    if [[ "$optional_command" == "-e" ]]; then
      if [[ -z "$PYTHONPATH" && -z "$DYLD_INSERT_LIBRARIES" ]]; then
        change_dir_activate
        # set_nuke_user_pref
        # set_env_vars
      else
        change_dir_activate
        # set_nuke_user_pref
        echo "Environment variables are already active"
        return 1
      fi

    elif [[ "$optional_command" == "-hou" ]]; then
      if [[ -z "$PYTHONPATH" && -z "$DYLD_INSERT_LIBRARIES" ]]; then
        change_dir_activate
        # set_nuke_user_pref
        # set_env_vars
        # python3 ./importhou/importhou.py || return 1
      else
        change_dir_activate
        # set_nuke_user_pref
        # python3 ./importhou/importhou.py || return 1
      fi

    # Add more subcommands as needed here, e.g.:
    # elif [[ "$optional_command" == "launch" ]]; then
    #   open -a "Nuke${nuke_version}"
    #   return
    fi

  else
    # No command: just activate and cd
    change_dir_activate
    # set_nuke_user_pref
    # set_env_vars
  fi
}
