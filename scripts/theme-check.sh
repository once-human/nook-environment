#!/usr/bin/env bash
# theme-check.sh: Feeds Nook theme status to Waybar top bar.
# Outputs JSON containing icon, active class, and tooltip.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_FILE="${REPO_ROOT}/.theme_state"
CURRENT_THEME="light"

if [[ -f "${STATE_FILE}" ]]; then
    CURRENT_THEME="$(cat "${STATE_FILE}")"
fi

if [[ "${CURRENT_THEME}" == "light" ]]; then
    # In light mode, display Moon icon to toggle to dark mode
    echo '{"text": "", "alt": "light", "tooltip": "Switch to Dark Mode", "class": "light-mode"}'
else
    # In dark mode, display Sun icon to toggle to light mode
    echo '{"text": "", "alt": "dark", "tooltip": "Switch to Light Mode", "class": "dark-mode"}'
fi
