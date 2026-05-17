# Nook Shell - Shell Prompt
# Restrained, minimalist shell prompt.

if command -v starship &>/dev/null; then
    # Let starship manage the prompt if it's installed
    # export STARSHIP_CONFIG="${HOME}/.config/starship.toml"
    true
else
    # Sleek, modern monochrome-first shell prompt fallback
    export PS1="\[\e[1;30m\][\[\e[1;36m\]nook-dev\[\e[1;30m\]] \[\e[1;34m\]\w\[\e[0m\] \[\e[1;32m\]❯\[\e[0m\] "
fi
