#!/usr/bin/env bash
# uninstall.sh: Professional uninstaller for Nook Shell
# Cleans up system files, GDM integrations, and restores user-level config backups.

set -euo pipefail

# Visual styling
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================================${NC}"
echo -e "${BLUE}        Nook Shell System Uninstaller                ${NC}"
echo -e "${BLUE}=====================================================${NC}"

CONFIG_DIR="${HOME}/.config"
DESKTOP_DST="/usr/share/wayland-sessions/nook-shell.desktop"
SESSION_DST="/usr/local/bin/nook-session"

# =====================================================
# 1. System Files Cleanup (Sudo scope)
# =====================================================
echo -e "\n${BLUE}Removing System-level GDM Integrations...${NC}"
echo -e "This script requires ${YELLOW}root/sudo privileges${NC} to remove files from system directories."

if ! sudo -v; then
    echo -e "${RED}Authentication failed.${NC} System-level uninstallation aborted."
    exit 1
fi

remove_system_file() {
    local target="$1"
    if [[ -f "$target" || -L "$target" ]]; then
        echo -e " -> Removing: $target"
        sudo rm "$target"
    fi

    # Attempt to restore the latest backup if any exists
    local backups
    backups=$(ls -t "${target}.backup_"* 2>/dev/null || true)
    if [[ -n "$backups" ]]; then
        local latest_backup
        latest_backup=$(echo "$backups" | head -n 1)
        echo -e " -> ${GREEN}Restoring system backup:${NC} $latest_backup -> $target"
        sudo mv "$latest_backup" "$target"
    fi
}

remove_system_file "$DESKTOP_DST"
remove_system_file "$SESSION_DST"

# =====================================================
# 2. Config Symlinks Cleanup (User scope)
# =====================================================
echo -e "\n${BLUE}Restoring User-level Sandboxed Environment...${NC}"

restore_user_symlink() {
    local target="$1"
    local name="$2"

    if [[ -L "$target" ]]; then
        echo -e " -> Removing ${name} symlink: $target"
        rm "$target"
        
        # Check for backups and restore the latest one
        local backups
        backups=$(ls -td "${target}.backup_"* 2>/dev/null || true)
        if [[ -n "$backups" ]]; then
            local latest_backup
            latest_backup=$(echo "$backups" | head -n 1)
            echo -e " -> ${GREEN}Restoring user backup:${NC} $latest_backup -> $target"
            mv "$latest_backup" "$target"
        fi
    fi
}

restore_user_symlink "${CONFIG_DIR}/waybar" "Waybar panel"
restore_user_symlink "${CONFIG_DIR}/wofi" "Wofi launcher"
restore_user_symlink "${CONFIG_DIR}/nook" "Nook core configurations"

echo -e "\n${GREEN}=====================================================${NC}"
echo -e "${GREEN}    Nook Shell Uninstalled Successfully!              ${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo -e "\nAll system wrapper files, GDM entries, and environment settings"
echo -e "have been removed. Your pre-installation configurations have been restored.\n"
