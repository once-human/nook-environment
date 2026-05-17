# Nook Shell Development Environment

This repository represents the reproducible, live shell development environment used to build, test, and run **Nook Shell**—a human-centric adaptive Linux desktop platform built on top of Hyprland and Wayland.

Unlike generic desktop "rices", this environment is designed with **rigorous engineering discipline**, featuring modular system-level configs, clean startup pipelines, live developer reload helpers, and custom shell integrations.

---

## Architectural Design

The environment operates via standard system symlinks, linking the development repository directly into the active system config directory. This enables instant hot-testing of layout, bar, launcher, or compositor changes.

```
~/Documents/Projects/nook-environment (Active Workspace)
↓ symlinked by setup.sh into ↓
~/.config/nook/
  ├── hypr/        → Sourced modularly via Hyprland shellOverrides
  ├── waybar/      → Sourced natively or via symlink to ~/.config/waybar
  ├── wofi/        → Symlinked natively to ~/.config/wofi
  ├── touchegg/    → Symlinked natively to ~/.config/touchegg
  ├── scripts/     → Integrated directly in PATH
  └── shell/       → Loaded inside ~/.zshrc or ~/.bashrc
```

This ensures a clean decoupling: your core development workspace **remains the single source of truth** while powering your active, live Linux session.

---

## Repository Structure

The layout is Linux-native, restrained, and strictly modular:

```
├── hypr/                      # Modular Hyprland compositor settings
│   ├── hyprland.conf          # Master entrypoint orchestrator
│   ├── environment.conf       # Wayland environment variables
│   ├── input.conf             # Keyboard, mouse, and touchpad settings
│   ├── gestures.conf          # 3-finger workspace swipe controls
│   ├── appearance.conf        # Premium visual styling (blur, borders, gaps)
│   ├── animations.conf        # Organic fluid curves & snappiness
│   ├── workspaces.conf        # Dynamic workspace behavior rules
│   ├── keybinds.conf          # Keyboard-first system shortcuts
│   └── startup.conf           # Panel (Waybar) & service launching
├── waybar/                    # Status bar widget configurations
│   ├── config.jsonc           # Custom left/center/right module layout
│   └── style.css              # Premium dark-theme glassmorphic stylesheet
├── wofi/                      # Centered desktop launcher
│   ├── config                 # Display dimensions & options
│   └── style.css              # Glassmorphic list selection styling
├── touchegg/                  # Touchpad system gesture fallbacks
│   └── touchegg.conf          # Custom gesture events mapping
├── shell/                     # Shell environment extensions
│   ├── env.sh                 # Developer path & log declarations
│   ├── aliases.sh             # Compiling, running, & diagnostic shortcuts
│   └── prompt.sh              # Restrained fallback prompt config
├── scripts/                   # System automation scripts
│   ├── setup.sh               # Safe installer & symlink constructor
│   └── nook-reload.sh         # Rapid shell desktop hot-reloader
└── DEVELOPMENT.md             # Developer workflow & debugging manual
```

---

## Quickstart Setup

To install and link this environment into your active desktop, run the setup script:

```bash
cd ~/Documents/Projects/nook-environment
./scripts/setup.sh
```

### What `setup.sh` does:
1. **Detects paths dynamically**: Identifies the exact active repository root.
2. **Backs up non-destructively**: Relocates any pre-existing configuration directories (e.g. `~/.config/nook`) to safety using timestamped directories (`*.backup_YYYYMMDD_HHMMSS`).
3. **Establishes symlinks**: Binds the repository and core apps (`waybar`, `wofi`, `touchegg`) to standard search locations in `~/.config`.
4. **Splicing integration**: Appends a single line `source = ~/.config/nook/hypr/hyprland.conf` to `~/.config/hypr/hyprland/shellOverrides/main.conf` so stock Hyprland loads the environment.

### Shell Integration
To activate Nook Shell aliases and environmental markers, append these lines to `~/.zshrc` or `~/.bashrc`:

```bash
# Nook Shell Dev Environment Integration
source ~/.config/nook/shell/env.sh
source ~/.config/nook/shell/aliases.sh
source ~/.config/nook/shell/prompt.sh
```

---

## Core Desktop Shortcuts

The default keybindings focus on a rapid, keyboard-first development workflow:

| Key Binding | Action |
|-------------|--------|
| `SUPER` + `RETURN` | Open developer terminal (`kitty`) |
| `SUPER` + `SPACE` | Open application launcher (`wofi`) |
| `SUPER` + `Q` | Kill active window |
| `SUPER` + `F` | Toggle fullscreen |
| `SUPER` + `V` | Toggle floating layout |
| `SUPER` + `H/J/K/L` | Navigate focus (Left / Down / Up / Right) |
| `SUPER` + `SHIFT` + `H/J/K/L` | Move active window (Left / Down / Up / Right) |
| `SUPER` + `[1-9]` | Direct switch to Workspace 1 to 9 |
| `SUPER` + `SHIFT` + `[1-9]` | Move active window to Workspace 1 to 9 |
| `SUPER` + `Scroll Wheel` | Cycle workspaces sequentially |
| `3-Finger Touchpad Swipe` | Seamless workspace swipe transitions |

---

## Developer Hot-Reloading

When editing configs inside your workspace, execute:
```bash
nook-reload
```
This script instantly parses compositor changes, destroys the current Waybar instance, starts a new Waybar session linking to your updated styling, and fires a clean desktop notification confirming reload.