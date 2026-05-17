# Nook Shell - Developer Shell Environment
# This file is sourced in .zshrc or .bashrc to configure development markers.

export NOOK_DEV_ENV=1
export NOOK_CONFIG_DIR="${HOME}/.config/nook"
export NOOK_SHELL_LOG="${NOOK_CONFIG_DIR}/nook.log"

# Add nook scripts path to shell PATH
if [[ -d "${NOOK_CONFIG_DIR}/scripts" ]]; then
    export PATH="${NOOK_CONFIG_DIR}/scripts:${PATH}"
fi
