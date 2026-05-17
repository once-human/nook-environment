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

# 2. Restart Waybar
echo " -> Restarting Waybar with Nook configurations..."
killall waybar 2>/dev/null || true

# Give it a fraction of a second to clean up the port / PID
sleep 0.2

waybar -c "${HOME}/.config/nook/waybar/config.jsonc" -s "${HOME}/.config/nook/waybar/style.css" > /dev/null 2>&1 &

# 3. Trigger a modern notification if notify-send exists
if command -v notify-send &>/dev/null; then
    notify-send -t 2000 -u low -e "Nook Shell" "Environment reloaded successfully"
fi

echo "==> Success! Nook Shell reloaded."
