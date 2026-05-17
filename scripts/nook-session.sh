#!/usr/bin/env bash
# Nook Shell - User-level Desktop Session Launcher
# Configures isolated environment boundaries and launches the compositor.

set -e

# Redirect session logs to user-relative nook.log
LOG_FILE="${HOME}/.config/nook/nook.log"
exec > >(tee -a "${LOG_FILE}") 2>&1

echo "====================================================="
echo "Starting Nook Shell Wayland Session..."
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo "====================================================="

# 1. Export Essential Wayland, XDG, and Portal environment variables
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland

# Toolkit backend overrides to lock system to native Wayland
export GDK_BACKEND="wayland,x11,*"
export QT_QPA_PLATFORM="wayland;xcb"
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

# 2. Export isolated Nook environment paths
export NOOK_DEV_ENV=1
export NOOK_CONFIG_DIR="${HOME}/.config/nook"
export PATH="${NOOK_CONFIG_DIR}/scripts:${PATH}"

# 3. Boot the nookd background daemon service dynamically
if command -v nookd &> /dev/null; then
    if systemctl --user is-active --quiet nookd.service; then
        echo "Supervised nookd.service active; restarting state engine"
        systemctl --user restart nookd.service
    else
        echo "Launching local nookd background daemon..."
        nookd &
        NOOKD_PID=$!
        trap 'kill $NOOKD_PID' EXIT
    fi
else
    echo "Info: nookd binary not found on system PATH; skipping daemon boot."
fi

# 4. Boot the main Hyprland Compositor using isolated Nook configuration
echo "Launching Hyprland compositor with isolated Nook configuration..."
exec Hyprland --config "${HOME}/.config/nook/hypr/hyprland.conf"
