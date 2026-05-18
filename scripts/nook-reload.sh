#!/usr/bin/env bash
# Nook Shell - Environment Reload Script
# Instantly reloads Hyprland compositor settings and restarts Waybar.

set -euo pipefail

echo "==> Reloading Nook Environment..."

# 1. Reload Hyprland configuration
if command -v hyprctl &>/dev/null; then
    echo " -> Hot-reloading Hyprland compositor..."
    hyprctl reload
else
    echo " -> WARNING: hyprctl is not available. Skipping compositor reload."
fi

# 2. Restart Waybar (Only if Nook waybar is actually running to avoid hijacking main environment waybar)
if pgrep -a waybar | grep -q 'nook/waybar'; then
    echo " -> Restarting Waybar with Nook configurations..."
    killall waybar 2>/dev/null || true
    sleep 0.2
    waybar -c "${HOME}/.config/nook/waybar/config.jsonc" -s "${HOME}/.config/nook/waybar/style.css" > /dev/null 2>&1 &
else
    echo " -> Skipping Waybar restart (Nook Waybar is not active in this session)."
fi

# 3. Restart Nook Quickshell Runtime
echo " -> Restarting Nook Quickshell..."
if [[ -f "${HOME}/.config/nook/scripts/nook-shell.sh" ]]; then
    "${HOME}/.config/nook/scripts/nook-shell.sh"
else
    echo " -> WARNING: nook-shell.sh not found. Skipping Quickshell restart."
fi

# 4. Trigger a modern notification if notify-send exists
if command -v notify-send &>/dev/null; then
    timeout 3 notify-send -t 2000 -u low -e "Nook Shell" "Environment reloaded successfully" &
fi

echo "==> Success! Nook Shell reloaded."
