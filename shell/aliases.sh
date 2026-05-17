# Nook Shell - Developer Aliases
# Short-cuts for the Nook Shell compositor and layout engineering workflow.

# Directory Navigations
alias nook-cd-env="cd ~/Documents/Projects/nook-environment"
alias nook-cd-shell="cd ~/Documents/Projects/nook-shell"

# Shell Engine Builds and Runs (Rust based nookd compositor daemon)
alias nook-build="cargo --manifest-path ~/Documents/Projects/nook-shell/nookd/Cargo.toml build"
alias nook-run="cargo --manifest-path ~/Documents/Projects/nook-shell/nookd/Cargo.toml run"
alias nook-test="cargo --manifest-path ~/Documents/Projects/nook-shell/nookd/Cargo.toml test"

# Reload & Diagnostics
alias nook-reload="~/.config/nook/scripts/nook-reload.sh"
alias nook-logs="tail -f ~/.config/nook/nook.log 2>/dev/null || journalctl -xe --user-unit=hyprland"

# Quick config editing shortcuts
alias nook-edit-hypr="nano ~/.config/nook/hypr/hyprland.conf"
alias nook-edit-waybar="nano ~/.config/nook/waybar/config.jsonc"
alias nook-edit-keybinds="nano ~/.config/nook/hypr/keybinds.conf"

# Nook Shell Process Controls
alias nook-shell-start="~/.config/nook/scripts/nook-shell.sh"
alias nook-shell-restart="~/.config/nook/scripts/nook-shell.sh"
