# Nook Shell System Installation & Integration Guide

This document defines the unified installation architecture, dependency metrics, and uninstallation workflows for **Nook Shell**, ensuring a highly stable, professional, and reproducible integration.

---

## 1. System Integration Flow

Nook Shell integrates directly with your system's display manager (GDM/SDDM/LightDM) without affecting or overwriting your active, daily-driver desktop environment or existing stock Hyprland configuration.

```
                  ┌──────────────────────────────┐
                  │  Nook Shell Repository Root  │
                  └──────────────┬───────────────┘
                                 │
                   Runs Unified  │ Link & Copy
                   Installer     ▼ Operations
  ┌─────────────────────────────────────────────────────────────┐
  │                                                             │
  │  User Configuration (No Root)    System Files (Sudo)        │
  │  - Symlink ~/.config/nook        - Copy nook-shell.desktop  │
  │  - Link waybar and wofi          - Copy nook-session        │
  │                                                             │
  └──────────────────────────────┬──────────────────────────────┘
                                 │
                                 ▼
                  ┌──────────────────────────────┐
                  │ GDM Selectable Nook Session  │
                  └──────────────────────────────┘
```

---

## 2. Dependency Matrix

The unified installer audits your host environment for standard core dependencies. If any utility is missing, it will log a warning indicating that the software should be resolved via your package manager:

| Binary | Target Package (Arch Linux) | Responsibility | Importance |
| :--- | :--- | :--- | :--- |
| `Hyprland` | `hyprland` | Compositor Core | **CRITICAL** |
| `qs` | `quickshell` (AUR) | GPU-Accelerated QML Overlays | **CRITICAL** |
| `waybar` | `waybar` | Status Bar Fallback | **REQUIRED** |
| `hypridle` | `hypridle` | Idle Timeout Daemon | **REQUIRED** |
| `hyprlock` | `hyprlock` | Screen Locking Client | **REQUIRED** |
| `wofi` / `fuzzel` | `wofi` or `fuzzel` | CLI Application Finder Fallback | **REQUIRED** |
| `grim` | `grim` | Screen Capture Client | **UTILITY** |
| `slurp` | `slurp` | Area Selection Target | **UTILITY** |
| `swww` | `swww` | Wallpaper Cache Manager | **UTILITY** |
| `brightnessctl` | `brightnessctl` | Screen Brightness OSD Trigger | **UTILITY** |
| `wpctl` | `wireplumber` | Audio PipeWire OSD Trigger | **UTILITY** |

---

## 3. Sandboxing & Safe Installation

To execute a clean, decoupled installation, run the following commands:

```bash
cd ~/Documents/Projects/nook-environment
chmod +x packaging/install/install.sh
./packaging/install/install.sh
```

### Installation Actions:
1.  **Dependency Audit**: Runs a non-blocking check on active binaries, printing a colored diagnostic table.
2.  **Backup Splicing**: Checks if `~/.config/nook` exists. If it is a folder, it backs it up to `~/.config/nook.backup_YYYYMMDD_HHMMSS` to ensure your data is never lost.
3.  **Config Symlinking**: Creates a symbolic link pointing `~/.config/nook` directly to your active workspace repository.
4.  **System Files Splicing**: Sudo is requested only to write integration files:
    *   Installs GDM Session to `/usr/share/wayland-sessions/nook-shell.desktop`
    *   Installs Session Wrapper to `/usr/local/bin/nook-session`

---

## 4. Zero-Trace Uninstallation

If you wish to remove Nook Shell and restore your pre-installation configurations, run the uninstaller script:

```bash
cd ~/Documents/Projects/nook-environment
chmod +x packaging/uninstall/uninstall.sh
./packaging/uninstall/uninstall.sh
```

### Uninstallation Actions:
1.  Prompts for sudo authorization.
2.  Removes GDM desktop files and `/usr/local/bin/nook-session`.
3.  Safely restores any system backups that were renamed during the installation.
4.  Deletes user-level symlinks (`~/.config/nook`, `~/.config/waybar`, `~/.config/wofi`) and restores the latest local backups, returning your desktop precisely to its pre-install state.

---

## 5. Troubleshooting & Diagnostics

If you encounter issues during execution, check these resources:

### Active Logs
All standard output, error dumps, and compositor broadcasts from your Nook session are captured in real-time under:
```bash
tail -f ~/.config/nook/nook.log
```

### GDM Sourcing Failure
If Nook Shell does not appear in your display manager, verify that GDM can parse the desktop template:
```bash
ls -l /usr/share/wayland-sessions/nook-shell.desktop
```
Ensure the target points to `/usr/local/bin/nook-session` and the file is readable by the `gdm` user group.
