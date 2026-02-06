# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# ┌────────────────────────────────────────────────────────┐
# │                     INITIALIZATION                     │
# └────────────────────────────────────────────────────────┘
eval "$(zoxide init bash)"
zf() {
  local dir
  # find folders, strip the ./ prefix, and launch fzf
  dir=$(find . -mindepth 1 -maxdepth 1 -type d | sed 's|^\./||' | fzf \
    --height 50% \
    --reverse \
    --preview 'ls -Cp --color=always {}' \
    --preview-window 'bottom' \
    --prompt "Local Jump > ")

  # If a selection was made, jump using zoxide
  if [ -n "$dir" ]; then
    z "$dir"
  fi
}
if [ -z "$SSH_AUTH_SOCK" ]; then
   eval "$(ssh-agent -s)" > /dev/null
fi

# ─── [ Omarchy Core ] ─────────────────────────────────────
# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# ─── [ Environment Variables ] ────────────────────────────



# ─── [ System Utilities ] ─────────────────────────────────
# Hyprland Display Controls
alias mon-fix="hyprctl keyword monitor HDMI-A-1, disable && hyprctl dispatch split-grabroguewindows"
alias mon-reset="hyprctl keyword monitor HDMI-A-1, disable && hyprctl dispatch split-resetallmonitors"
alias mon-on="hyprctl keyword monitor HDMI-A-1, preferred, auto, 1"
alias mon-ls="hyprctl monitors | grep 'Monitor'"

# Development & Scripts
alias venv='source ./.venv/bin/activate'

# ┌────────────────────────────────────────────────────────┐
# │                 EXTERNAL TOOL SETUP                    │
# └────────────────────────────────────────────────────────┘

# ─── [ SDKMAN ] ───────────────────────────────────────────
# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
