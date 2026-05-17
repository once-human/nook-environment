#!/usr/bin/env bash
# Nook Shell - Live Development Environment Setup Script
# Automates the symlink integrations and base configuration splicing safely.

set -euo pipefail

# Visual styling
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================================${NC}"
echo -e "${BLUE}       Nook Shell Live Environment Installer         ${NC}"
echo -e "${BLUE}=====================================================${NC}"

# Detect the active repository root dynamically
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${HOME}/.config"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

echo -e " -> Repository Root: ${GREEN}${REPO_ROOT}${NC}"
echo -e " -> System Config:   ${GREEN}${CONFIG_DIR}${NC}"

# Function to safely create a symlink with backup handling
setup_symlink() {
    local source_dir="$1"
    local target_link="$2"
    local name="$3"

    echo -e "\nConfiguring ${BLUE}${name}${NC} integration..."

    # If target already exists
    if [[ -e "${target_link}" || -L "${target_link}" ]]; then
        # If it is a symlink
        if [[ -L "${target_link}" ]]; then
            local current_link
            current_link="$(readlink -f "${target_link}")"
            if [[ "${current_link}" == "${source_dir}" ]]; then
                echo -e " -> ${GREEN}Already linked correctly:${NC} ${target_link} -> ${source_dir}"
                return 0
            else
                echo -e " -> ${YELLOW}Updating symlink:${NC} pointing from ${current_link} to ${source_dir}"
                rm "${target_link}"
            fi
        else
            # It is a physical file or directory
            local backup_path="${target_link}.backup_${TIMESTAMP}"
            echo -e " -> ${YELLOW}Backup initiated:${NC} Moving existing ${target_link} to ${backup_path}"
            mv "${target_link}" "${backup_path}"
        fi
    fi

    # Create the symlink
    echo -e " -> ${GREEN}Linking:${NC} ${target_link} -> ${source_dir}"
    ln -s "${source_dir}" "${target_link}"
}

# 1. Link Nook main directory
setup_symlink "${REPO_ROOT}" "${CONFIG_DIR}/nook" "Nook core workspace"

# 2. Link individual app configs to standard locations for native launches
setup_symlink "${CONFIG_DIR}/nook/waybar" "${CONFIG_DIR}/waybar" "Waybar bar"
setup_symlink "${CONFIG_DIR}/nook/wofi" "${CONFIG_DIR}/wofi" "Wofi launcher"
setup_symlink "${CONFIG_DIR}/nook/touchegg" "${CONFIG_DIR}/touchegg" "Touchegg gesture fallback"

# 3. Splice into base Hyprland config non-destructively
echo -e "\nConfiguring ${BLUE}Hyprland Splice Override${NC}..."
HYPR_OVERRIDE_DIR="${CONFIG_DIR}/hypr/hyprland/shellOverrides"
HYPR_OVERRIDE_FILE="${HYPR_OVERRIDE_DIR}/main.conf"
SPLICE_CMD="source = ~/.config/nook/hypr/hyprland.conf"

# Ensure the parent folders exist
mkdir -p "${HYPR_OVERRIDE_DIR}"

if [[ ! -f "${HYPR_OVERRIDE_FILE}" ]]; then
    echo -e " -> Creating empty overrides file: ${HYPR_OVERRIDE_FILE}"
    touch "${HYPR_OVERRIDE_FILE}"
fi

# Inject the splice command if not already present
if grep -Fxq "${SPLICE_CMD}" "${HYPR_OVERRIDE_FILE}"; then
    echo -e " -> ${GREEN}Splicing check passed:${NC} Override already active in ${HYPR_OVERRIDE_FILE}"
else
    echo -e " -> ${YELLOW}Splicing environment:${NC} Injecting nook load hook into ${HYPR_OVERRIDE_FILE}"
    echo "${SPLICE_CMD}" >> "${HYPR_OVERRIDE_FILE}"
fi

# Make helper scripts executable
echo -e "\nAdjusting helper script permissions..."
chmod +x "${REPO_ROOT}/scripts/nook-reload.sh"
chmod +x "${REPO_ROOT}/scripts/setup.sh"
chmod +x "${REPO_ROOT}/scripts/nook-session.sh"
chmod +x "${REPO_ROOT}/scripts/install-session.sh"
echo -e " -> ${GREEN}Done:${NC} All developer helper and session scripts are now executable."

echo -e "\n${GREEN}=====================================================${NC}"
echo -e "${GREEN}    Setup completed successfully!                    ${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo -e "\nTo enable shell environment variables and convenient aliases,"
echo -e "append the following lines to your shell profile (e.g. ~/.zshrc or ~/.bashrc):\n"
echo -e "   ${BLUE}# Nook Shell Dev Environment Integration${NC}"
echo -e "   source ~/.config/nook/shell/env.sh"
echo -e "   source ~/.config/nook/shell/aliases.sh"
echo -e "   source ~/.config/nook/shell/prompt.sh\n"
echo -e "Start or hot-reload your active desktop with: ${GREEN}nook-reload${NC}\n"
