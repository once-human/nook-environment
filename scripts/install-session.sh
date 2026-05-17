#!/usr/bin/env bash
# Nook Shell - Wayland Session GDM Installer Script
# Installs system-wide wrappers and session metadata safely.

set -euo pipefail

# Visual styling
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================================${NC}"
echo -e "${BLUE}     Nook Shell Session System GDM Installer        ${NC}"
echo -e "${BLUE}=====================================================${NC}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Local source files
LOCAL_WRAPPER="${REPO_ROOT}/packaging/nook-session"
LOCAL_DESKTOP="${REPO_ROOT}/packaging/nook-shell.desktop"
LOCAL_LAUNCHER="${REPO_ROOT}/scripts/nook-session.sh"

# Target system paths
SYSTEM_WRAPPER="/usr/local/bin/nook-session"
SYSTEM_DESKTOP="/usr/share/wayland-sessions/nook-shell.desktop"

# 1. Adjust local execution permissions
echo -e "Adjusting local session helper permissions..."
chmod +x "${LOCAL_LAUNCHER}"
chmod +x "${LOCAL_WRAPPER}"
echo -e " -> ${GREEN}Done:${NC} Made local launchers and wrappers executable."

# 2. Deploy system-wide delegation wrapper
echo -e "\nDeploying global session wrapper..."
echo -e " -> Copying ${LOCAL_WRAPPER} to ${SYSTEM_WRAPPER} (Sudo required)"
sudo cp "${LOCAL_WRAPPER}" "${SYSTEM_WRAPPER}"
sudo chmod +x "${SYSTEM_WRAPPER}"
sudo chown root:root "${SYSTEM_WRAPPER}"
echo -e " -> ${GREEN}Success:${NC} Global wrapper deployed."

# 3. Deploy GDM Wayland session metadata
echo -e "\nDeploying GDM session metadata..."
echo -e " -> Copying ${LOCAL_DESKTOP} to ${SYSTEM_DESKTOP} (Sudo required)"
sudo mkdir -p "$(dirname "${SYSTEM_DESKTOP}")"
sudo cp "${LOCAL_DESKTOP}" "${SYSTEM_DESKTOP}"
sudo chmod 644 "${SYSTEM_DESKTOP}"
sudo chown root:root "${SYSTEM_DESKTOP}"
echo -e " -> ${GREEN}Success:${NC} GDM Wayland session entry deployed."

echo -e "\n${GREEN}=====================================================${NC}"
echo -e "${GREEN}    Session GDM Integration Complete!                ${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo -e "\nNook Shell is now registered as a Wayland session."
echo -e "You can select ${BLUE}Nook Shell${NC} directly from your GDM login screen!"
echo -e "This session is fully isolated from your stock Hyprland desktop.\n"
