#!/usr/bin/env bash
# theme-toggle.sh: Switches Nook Shell between Light and Dark modes system-wide.
# Seamlessly transitions GTK interfaces, Hyprland borders, Waybar colors, and Wofi search styling.

set -euo pipefail

# Detect repository root dynamically (parent folder of scripts/)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_FILE="${REPO_ROOT}/.theme_state"
CURRENT_THEME="light"

# 1. Determine active theme state
if [[ -f "${STATE_FILE}" ]]; then
    CURRENT_THEME="$(cat "${STATE_FILE}")"
fi

if [[ "${CURRENT_THEME}" == "light" ]]; then
    NEW_THEME="dark"
else
    NEW_THEME="light"
fi

echo "==> Transitioning Nook Shell to [${NEW_THEME}] mode..."

# 2. Update state file
echo "${NEW_THEME}" > "${STATE_FILE}"

# 3. Swap modular symlinks in the development repository workspace
ln -sf "colors.conf.${NEW_THEME}" "${REPO_ROOT}/hypr/colors.conf"
ln -sf "colors.css.${NEW_THEME}" "${REPO_ROOT}/waybar/colors.css"
ln -sf "style.css.${NEW_THEME}" "${REPO_ROOT}/wofi/style.css"

# 4. Toggle GTK/Gnome applications preference
if [[ "${NEW_THEME}" == "dark" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
fi

# 5. Flush and apply changes dynamically under Wayland
# Reload Hyprland borders & shadows
hyprctl reload || true

# Signal Waybar to hot-reload its CSS instantly without process destruction (SIGUSR2)
pkill -USR2 waybar || true

# Signal Waybar custom/theme-toggle module to refresh immediately (SIGRTMIN+8)
pkill -RTMIN+8 waybar || true

# 6. Beautiful system notification confirmation
if command -v notify-send &>/dev/null; then
    ICON=""
    if [[ "${NEW_THEME}" == "dark" ]]; then
        ICON=""
    fi
    timeout 3 notify-send -t 1500 -u low -e "Nook Shell" "${ICON} Switched to ${NEW_THEME} mode" &
fi

echo "==> Success! Workspace shifted to ${NEW_THEME} mode."
