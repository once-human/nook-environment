#!/usr/bin/env bash
# install.sh: Professional unified installer for Nook Shell desktop environment
# Coordinates dependency audits, safe configuration sandboxing, and GDM integration.

set -euo pipefail

# Visual styling
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================================${NC}"
echo -e "${BLUE}        Nook Shell Unified System Installer          ${NC}"
echo -e "${BLUE}=====================================================${NC}"

# Detect repository root dynamically
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CONFIG_DIR="${HOME}/.config"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

echo -e " -> Repository Root: ${GREEN}${REPO_ROOT}${NC}"
echo -e " -> System Config:   ${GREEN}${CONFIG_DIR}${NC}"

# =====================================================
# 1. Dependency Auditor
# =====================================================
echo -e "\n${BLUE}Performing System Dependency Audit...${NC}"

# Array of target binary dependencies to audit
declare -A DEPS=(
    ["Hyprland"]="Compositor Core"
    ["qs"]="Quickshell Engine"
    ["waybar"]="Fallback Status Panel"
    ["hypridle"]="Idle Management Daemon"
    ["hyprlock"]="Screen Locking Client"
    ["wofi"]="CLI Launcher (Fallback)"
    ["fuzzel"]="CLI Launcher (Alternative)"
    ["grim"]="Screen Capture Utility"
    ["slurp"]="Screen Area Selector"
    ["swww"]="Wallpaper Manager"
    ["brightnessctl"]="Backlight Controller"
    ["wpctl"]="Audio controller (PipeWire)"
)

MISSING_COUNT=0
FOUND_COUNT=0

printf "%-18s | %-24s | %-12s\n" "Dependency" "Description" "Status"
printf "%-18s-|-%-24s-|-%-12s\n" "------------------" "------------------------" "------------"

for cmd in "${!DEPS[@]}"; do
    if command -v "$cmd" &>/dev/null; then
        printf "%-18s | %-24s | ${GREEN}%-12s${NC}\n" "$cmd" "${DEPS[$cmd]}" "FOUND"
        FOUND_COUNT=$((FOUND_COUNT + 1))
    else
        # Wofi/Fuzzel are alternatives, so treat missing as warning rather than failure
        if [[ "$cmd" == "wofi" || "$cmd" == "fuzzel" ]]; then
            printf "%-18s | %-24s | ${YELLOW}%-12s${NC}\n" "$cmd" "${DEPS[$cmd]}" "WARN (OPT)"
        else
            printf "%-18s | %-24s | ${RED}%-12s${NC}\n" "$cmd" "${DEPS[$cmd]}" "MISSING"
            MISSING_COUNT=$((MISSING_COUNT + 1))
        fi
    fi
done

echo -e "\nAudit Completed: ${GREEN}${FOUND_COUNT} found${NC}, ${RED}${MISSING_COUNT} missing${NC}."

if [[ $MISSING_COUNT -gt 0 ]]; then
    echo -e "${YELLOW}Warning:${NC} Some required core dependencies are missing. Nook Shell will install,"
    echo -e "but please ensure you install missing utilities using your package manager (e.g. pacman)."
fi

# =====================================================
# 2. Config Sandboxing & Symlinking (User scope)
# =====================================================
echo -e "\n${BLUE}Configuring User-level Sandboxed Environment...${NC}"
TARGET_LINK="${CONFIG_DIR}/nook"

if [[ -e "${TARGET_LINK}" || -L "${TARGET_LINK}" ]]; then
    if [[ -L "${TARGET_LINK}" ]]; then
        current_link="$(readlink -f "${TARGET_LINK}")"
        if [[ "${current_link}" == "${REPO_ROOT}" ]]; then
            echo -e " -> ${GREEN}Already linked correctly:${NC} ${TARGET_LINK} -> ${REPO_ROOT}"
        else
            echo -e " -> ${YELLOW}Updating symlink:${NC} pointing from ${current_link} to ${REPO_ROOT}"
            rm "${TARGET_LINK}"
            ln -s "${REPO_ROOT}" "${TARGET_LINK}"
        fi
    else
        # Physical folder exists, back it up
        BACKUP_PATH="${TARGET_LINK}.backup_${TIMESTAMP}"
        echo -e " -> ${YELLOW}Backup initiated:${NC} Moving existing ${TARGET_LINK} to ${BACKUP_PATH}"
        mv "${TARGET_LINK}" "${BACKUP_PATH}"
        ln -s "${REPO_ROOT}" "${TARGET_LINK}"
    fi
else
    echo -e " -> ${GREEN}Linking active configuration:${NC} ${TARGET_LINK} -> ${REPO_ROOT}"
    ln -s "${REPO_ROOT}" "${TARGET_LINK}"
fi

# Configure Waybar and Wofi helper links dynamically for native launches
setup_user_symlink() {
    local src="$1"
    local dst="$2"
    local name="$3"
    
    if [[ -e "$dst" || -L "$dst" ]]; then
        if [[ -L "$dst" ]]; then
            rm "$dst"
        else
            mv "$dst" "${dst}.backup_${TIMESTAMP}"
        fi
    fi
    ln -s "$src" "$dst"
    echo -e " -> Linked ${name} configuration safely."
}

setup_user_symlink "${TARGET_LINK}/waybar" "${CONFIG_DIR}/waybar" "Waybar status panel"
setup_user_symlink "${TARGET_LINK}/wofi" "${CONFIG_DIR}/wofi" "Wofi application launcher"

# =====================================================
# 3. GDM Desktop Session Integration (System scope)
# =====================================================
DESKTOP_SRC="${REPO_ROOT}/packaging/gdm/nook-shell.desktop"
SESSION_SRC="${REPO_ROOT}/packaging/session/nook-session"

DESKTOP_DST="/usr/share/wayland-sessions/nook-shell.desktop"
SESSION_DST="/usr/local/bin/nook-session"

echo -e "\n${BLUE}Configuring System-level GDM Session...${NC}"
echo -e "This script requires ${YELLOW}root/sudo privileges${NC} to install files into system directories."

# Prompt for sudo authentication
if ! sudo -v; then
    echo -e "${RED}Authentication failed.${NC} System-level integration bypassed."
    exit 1
fi

install_system_file() {
    local src="$1"
    local dst="$2"
    
    if [[ -f "$dst" ]]; then
        sudo mv "$dst" "${dst}.backup_${TIMESTAMP}"
    fi
    sudo cp "$src" "$dst"
    sudo chmod +r "$dst"
}

# Copy session template and launch wrapper
install_system_file "$DESKTOP_SRC" "$DESKTOP_DST"
echo -e " -> Installed GDM session entry: ${GREEN}${DESKTOP_DST}${NC}"

install_system_file "$SESSION_SRC" "$SESSION_DST"
sudo chmod +x "$SESSION_DST"
echo -e " -> Installed launch wrapper:    ${GREEN}${SESSION_DST}${NC}"

echo -e "\n${GREEN}=====================================================${NC}"
echo -e "${GREEN}    Nook Shell Installed Successfully!                ${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo -e "\nNook Shell is now selectable directly at GDM login manager."
echo -e "It coexists cleanly without modifying your daily-driver compositor configurations."
echo -e "To undo this installation at any time, execute the uninstaller:\n"
echo -e "   ${BLUE}./packaging/uninstall/uninstall.sh${NC}\n"
