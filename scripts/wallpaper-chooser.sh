#!/usr/bin/env bash
# wallpaper-chooser.sh: Launches visual GTK image chooser and sets active wallpaper under hyprpaper dynamically.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PICKER_SCRIPT="${SCRIPT_DIR}/wallpaper-picker.py"

# 1. Run visual GTK photo picker
if ! SELECTED_IMAGE=$("${PICKER_SCRIPT}"); then
    echo "Wallpaper selection cancelled by user."
    exit 0
fi

# Ensure we extract only the last line (the pure file path) to filter out any GTK stdout noise
SELECTED_IMAGE=$(tail -n 1 <<< "${SELECTED_IMAGE}")

# 2. Check if selected file exists
if [[ ! -f "${SELECTED_IMAGE}" ]]; then
    notify-send -t 2000 -u critical -e "Nook Shell" "❌ Selected file does not exist! (${SELECTED_IMAGE})"
    exit 1
fi

echo "==> Setting active wallpaper to: ${SELECTED_IMAGE}"

# 3. Apply the wallpaper dynamically to the active shell and hyprpaper
/home/onkar/.config/quickshell/ii/scripts/colors/switchwall.sh --image "${SELECTED_IMAGE}" || true

# Control hyprpaper dynamically
if pgrep -x hyprpaper >/dev/null; then
    echo " -> Preloading selected wallpaper in hyprpaper..."
    hyprctl hyprpaper preload "${SELECTED_IMAGE}" || true
    echo " -> Setting active wallpaper on monitor eDP-1..."
    hyprctl hyprpaper wallpaper "eDP-1,${SELECTED_IMAGE}" || true
fi

# Persist the configuration in the environment configuration file
CONF_FILE="${HOME}/.config/nook/hypr/hyprpaper.conf"
if [[ -f "${CONF_FILE}" ]]; then
    echo " -> Persisting wallpaper path in hyprpaper.conf..."
    cat > "${CONF_FILE}" << EOF
preload = ${SELECTED_IMAGE}
wallpaper = eDP-1,${SELECTED_IMAGE}
splash = false
EOF
fi

# 4. Notify of success with a gorgeous aesthetic notification
notify-send -t 2000 -u low -e "Nook Shell" "🎨 Wallpaper updated smoothly!"
echo "==> Success! Wallpaper updated."
