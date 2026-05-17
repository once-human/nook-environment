# Research: Illogical Impulse Architecture Notes
## Cohesion, Configuration Splicing, and Layout Extraction

This document analyzes the structural patterns of the active **Illogical Impulse** framework on the system to extract core engineering patterns for Nook Shell, without replicating its complexity or dependency overhead.

---

## 1. Analysis of Illogical Impulse Structure

Illogical Impulse operates as a highly opinionated, structured environment built on Hyprland. Its main directory (`~/.config/hypr`) is split into a core baseline and user-level overrides:

```
~/.config/hypr/
├── hyprland.conf            # Main loader executing standard-to-custom pipeline
├── monitors.conf            # Screen-specific configuration
├── workspaces.conf          # Initial workspace states
├── hyprland/                # Core system configurations
│   ├── colors.conf          # Dynamic theme variables
│   ├── env.conf             # Environment settings
│   ├── execs.conf           # Autostart applications
│   ├── general.conf         # Baseline window metrics
│   ├── keybinds.conf        # System-level keyboard layout mappings
│   ├── rules.conf           # Window placement and layout constraints
│   ├── variables.conf       # Core variables (animations, gestures)
│   └── shellOverrides/      # Custom splicing integration folder
└── custom/                  # User specific configurations (overwrites general.conf)
    ├── env.conf
    ├── execs.conf
    ├── general.conf
    ├── keybinds.conf
    └── rules.conf
```

### Why it feels cohesive:
* **The Custom Pipeline Pattern**: The core configuration loads first, establishing standard keybindings and windows. It then executes a `source=custom/*.conf` script sequence. This lets user overrides safely redefine general settings (like border size, active borders, gaps) without altering baseline window control.
* **Proportional Scaling**: Gaps (`gaps_in` and `gaps_out`) scale linearly. Active borders contrast cleanly with inactive window layers, creating logical separation without intense color clashes.
* **Clean Splice Hooks**: Utilizing empty integration hooks (like `shellOverrides/main.conf`) lets external tools (like Nook Environment) hook directly into the startup sequence seamlessly.

---

## 2. Extraction for Nook Shell Design

Nook Shell adopts the following refined principles based on these observations:

### Decoupled Modularity
Instead of creating a monolithic, multi-folder structure that is prone to break during updates, Nook Shell maintains a **restrained, self-contained shell folder** (`~/.config/nook`).
* Compositor settings remain close to stock Hyprland defaults.
* Splicing into other setups is restricted to a single hook (`shellOverrides/main.conf`), leaving system files completely clean and untouched.

### Visual Proportions & Metrics
To replicate the polished spatial harmony of modern tiling setups, Nook Shell implements:
1. **Symmetrical Overlay Margins**: Sidebars, app selectors, and system menus align perfectly with active workspace layouts (e.g. margin metrics matching `gaps_out`).
2. **Harmonized Borders**: Active element borders utilize HSL-tailored subtle transparency scales (`rgba(ffffff2b)`) rather than vibrant primary colors, aligning with the visual rest of active windows.
