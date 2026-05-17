#!/usr/bin/env bash
# nook-shell.sh: Process manager and autostart script for the Nook Quickshell desktop shell.
# Integrates the nook-shell QML panels into the active Hyprland environment.

set -euo pipefail

# Absolute path to the sibling nook-shell repository's QML directory
SHELL_DIR="/home/onkar/Documents/Projects/nook-shell/shell"

# Ensure the source layout exists
if [[ ! -d "${SHELL_DIR}" ]]; then
    echo "ERROR: Nook Shell QML source directory not found at: ${SHELL_DIR}" >&2
    exit 1
fi

echo "==> Initializing Nook Shell Quickshell runtime..."

# Terminate active quickshell instances to prevent resource or Wayland socket clashes
if pgrep -x quickshell >/dev/null; then
    echo " -> Terminating existing Quickshell instance..."
    killall quickshell 2>/dev/null || true
    sleep 0.25
fi

# Launch the quickshell engine pointing to our custom layout, detached from the caller
echo " -> Launching Quickshell from: ${SHELL_DIR}"
quickshell -p "${SHELL_DIR}" > /dev/null 2>&1 &

echo "==> Success! Nook Shell autostart completed."
