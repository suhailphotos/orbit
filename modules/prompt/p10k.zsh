# modules/prompt/p10k.zsh
# Initialize Powerlevel10k if present (interactive shells only)
[[ -o interactive ]] || return 0

_p10k_loaded=0

# Try Oh My Zsh theme first if OMZ exists
if [[ -d "${ZSH:-$HOME/.oh-my-zsh}" && -r "${ZSH:-$HOME/.oh-my-zsh}/oh-my-zsh.sh" ]]; then
  ZSH="${ZSH:-$HOME/.oh-my-zsh}"
  ZSH_THEME="powerlevel10k/powerlevel10k"
  source "$ZSH/oh-my-zsh.sh"
  _p10k_loaded=1
else
  # Fallback: common theme paths (Homebrew/macOS + typical Linux)
  for p in \
    "/opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme" \
    "/usr/local/share/powerlevel10k/powerlevel10k.zsh-theme" \
    "/usr/share/powerlevel10k/powerlevel10k.zsh-theme"
  do
    if [[ -r "$p" ]]; then
      source "$p"; _p10k_loaded=1; break
    fi
  done
fi

# Load user config if present
[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

(( _p10k_loaded )) || return 1
