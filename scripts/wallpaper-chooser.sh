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

# 3. Apply the wallpaper dynamically to all monitors in hyprpaper
hyprctl hyprpaper wallpaper ",${SELECTED_IMAGE}" || {
    notify-send -t 2000 -u critical -e "Nook Shell" "❌ Failed to set hyprpaper wallpaper!"
    exit 1
}

# 4. Notify of success with a gorgeous aesthetic notification
notify-send -t 2000 -u low -e "Nook Shell" "🎨 Wallpaper updated smoothly!"
echo "==> Success! Wallpaper updated."
