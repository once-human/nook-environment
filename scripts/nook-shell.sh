#!/usr/bin/env bash
# nook-shell.sh: Process manager and autostart script for the Nook Quickshell desktop shell.
# Safely terminates Quickshell now that the Shelf has been replaced by Rofi.

set -euo pipefail

echo "==> Terminating Nook Shell Quickshell runtime (Shelf removed)..."

# Terminate active quickshell instances to prevent resource or Wayland socket clashes
if pgrep -x quickshell >/dev/null; then
    echo " -> Terminating existing Quickshell instance..."
    killall quickshell 2>/dev/null || true
    sleep 0.25
fi

echo "==> Success! Nook Shell Shelf removed."
