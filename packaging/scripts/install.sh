#!/usr/bin/env bash
# install.sh: Safe, modular installation coordinator for Nook GDM session integration
# Validates paths, manages backups, copies entries, and sets permissions.

set -euo pipefail

# Visual styling
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================================${NC}"
echo -e "${BLUE}        Nook Shell GDM Desktop Session Installer     ${NC}"
echo -e "${BLUE}=====================================================${NC}"

# Define dynamic paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGING_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

DESKTOP_SRC="${PACKAGING_ROOT}/gdm/nook-shell.desktop"
SESSION_SRC="${PACKAGING_ROOT}/session/nook-session"

DESKTOP_DST="/usr/share/wayland-sessions/nook-shell.desktop"
SESSION_DST="/usr/local/bin/nook-session"

# Safety check: Verify source files exist in repository
if [[ ! -f "$DESKTOP_SRC" || ! -f "$SESSION_SRC" ]]; then
    echo -e "${RED}Error:${NC} Source template files not found in repository packaging layout."
    exit 1
fi

# Function to copy file with sudo and backup handling
install_system_file() {
    local src="$1"
    local dst="$2"
    local name="$3"

    echo -e "\nInstalling ${BLUE}${name}${NC} to ${dst}..."

    # If target already exists, back it up
    if [[ -f "$dst" ]]; then
        local backup_path="${dst}.backup_$(date +%Y%m%d_%H%M%S)"
        echo -e " -> ${YELLOW}Backup initiated:${NC} Moving existing ${dst} to ${backup_path}"
        sudo mv "$dst" "$backup_path"
    fi

    # Perform the copy operation
    echo -e " -> ${GREEN}Copying:${NC} ${src} -> ${dst}"
    sudo cp "$src" "$dst"
    sudo chmod +r "$dst"
}

# Prompt user for authentication confirmation before launching sudo commands
echo -e "This script requires ${YELLOW}root/sudo privileges${NC} to install session files into system directories."
echo -e "System Directories targeted:"
echo -e "  - ${GREEN}${DESKTOP_DST}${NC}"
echo -e "  - ${GREEN}${SESSION_DST}${NC}"
echo

# Perform sudo validation hook
if ! sudo -v; then
    echo -e "${RED}Authentication failed.${NC} Session integration aborted."
    exit 1
fi

# Keep-alive: update user's cached credentials for duration of script execution
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# 1. Install GDM Session Desktop Entry template
install_system_file "$DESKTOP_SRC" "$DESKTOP_DST" "GDM session entry"

# 2. Install Nook Launch Wrapper script
install_system_file "$SESSION_SRC" "$SESSION_DST" "Nook session launch wrapper"
sudo chmod +x "$SESSION_DST"
echo -e " -> ${GREEN}Set Executable permissions:${NC} ${SESSION_DST} is now executable."

echo -e "\n${GREEN}=====================================================${NC}"
echo -e "${GREEN}    GDM Desktop Session Integration Completed!        ${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo -e "\nYou can now select and log directly into ${BLUE}Nook Shell${NC} from GDM."
echo -e "This session runs isolated and will not interfere with stock Hyprland or GNOME profiles.\n"
