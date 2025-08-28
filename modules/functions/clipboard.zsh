# Linux/WSL clipboard shim for pbcopy/pbpaste
[[ $ORBIT_PLATFORM == linux || $ORBIT_PLATFORM == wsl ]] || return 0

_have() { command -v "$1" >/dev/null 2>&1; }

# OSC52 copy: sends clipboard over the terminal (works over SSH/tmux if allowed)
_osc52_copy() {
  local data; data=$(base64 | tr -d '\n')
  if [[ -n ${TMUX-} ]]; then
    printf '\ePtmux;\e]52;c;%s\a\e\\' "$data" >/dev/tty
  else
    printf '\e]52;c;%s\a' "$data" >/dev/tty
  fi
}

pbcopy() {
  # Wayland, then X11, then WSL, then OSC52 fallback
  if _have wl-copy;        then wl-copy;                                       return $?; fi
  if _have xclip;          then xclip -selection clipboard;                    return $?; fi
  if _have xsel;           then xsel --clipboard --input;                      return $?; fi
  if _have clip.exe;       then cat | clip.exe;                                return $?; fi  # WSL → Windows
  _osc52_copy
}

pbpaste() {
  if _have wl-paste;       then wl-paste -n;                                   return $?; fi
  if _have xclip;          then xclip -selection clipboard -o;                 return $?; fi
  if _have xsel;           then xsel --clipboard --output;                     return $?; fi
  if _have powershell.exe; then powershell.exe -NoProfile -Command 'Get-Clipboard' 2>/dev/null; return $?; fi
  echo "pbpaste: no clipboard program available" >&2
  return 1
}
