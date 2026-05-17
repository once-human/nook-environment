# Nook Shell Session & Launch Architecture

This document specifies the GDM (Gnome Display Manager) integration architecture for **Nook Shell**, detailing the dual-stage session delegation mechanism, environment boundaries, and portal integration.

---

## 1. Dual-Stage Launch Flow

To keep Nook Shell decoupled from standard system packaging limits and fully isolated from your daily driver configuration, Nook implements a **Dual-Stage Launch Delegation Flow**:

```
 ┌──────────────────────┐
 │    GDM Log-In Screen │
 └──────────┬───────────┘
            │ Selects Nook Shell
            ▼
 ┌──────────────────────┐
 │  nook-shell.desktop  │  Reads metadata inside /usr/share/wayland-sessions/
 └──────────┬───────────┘
            │ Exec = /usr/local/bin/nook-session
            ▼
 ┌──────────────────────┐
 │ nook-session wrapper │  System-level shell wrapper in /usr/local/bin/
 └──────────┬───────────┘
            │ Resolves $HOME dynamically and delegates to:
            ▼
 ┌──────────────────────┐
 │   nook-session.sh    │  User-level custom script inside ~/.config/nook/scripts/
 └──────────┬───────────┘
            │ Exports isolated Nook env variables & boots nookd services
            ▼
 ┌──────────────────────┐
 │  Hyprland Compositor │  Launches exec Hyprland --config ~/.config/nook/hypr/hyprland.conf
 └──────────────────────┘
```

### Stage 1: The System Wrapper (`/usr/local/bin/nook-session`)
Display managers (GDM, SDDM, LightDM) execute sessions under system scopes. Hardcoding absolute paths to a specific user's home folder is an anti-pattern.
Nook solves this by placing a lightweight, global wrapper inside `/usr/local/bin/nook-session`. This script dynamically captures the active `$HOME` variable of the logging-in user and routes execution directly to their local `~/.config/nook/scripts/nook-session.sh` configuration, enabling seamless local developer updates without touching root folders again.

### Stage 2: The Local Session Launcher (`~/.config/nook/scripts/nook-session.sh`)
Running in the user's environment, this script:
1.  Exports essential toolkit environment flags to lock the session to native Wayland.
2.  Ensures proper DBus socket initialization and XDG environment declarations.
3.  Initializes the `nookd` system daemon.
4.  Launches the target Hyprland compositor strictly targeted to Nook's configuration:
    `exec Hyprland --config "${HOME}/.config/nook/hypr/hyprland.conf"`

---

## 2. Environment Variables & Portals

To maintain portal consistency (essential for screensharing, file dialogs, and window captures), the launcher registers variables before booting the compositor:

```bash
# XDG Desktop Declarations
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland

# Toolkit Backends Locked to Native Wayland
export GDK_BACKEND=wayland,x11,*
export QT_QPA_PLATFORM="wayland;xcb"
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland
```

*   **Desktop Matching**: Declaring `XDG_CURRENT_DESKTOP=Hyprland` ensures that standard `xdg-desktop-portal-hyprland` and `xdg-desktop-portal-wlr` instances map portal calls accurately, retaining full compatibility with standard Hyprland screenshot and screen-sharing utilities.

---

## 3. Session Debugging Checklist

If Nook Shell fails to load from GDM, verify the following boundary conditions:

1.  **Wrapper Permissions**: Check if `/usr/local/bin/nook-session` is executable:
    ```bash
    ls -l /usr/local/bin/nook-session
    ```
2.  **Local Launcher Path**: Confirm your repository is symlinked correctly:
    ```bash
    ls -l ~/.config/nook/scripts/nook-session.sh
    ```
3.  **GDM Session Log**: Tail journalctl to see Wayland startup error trace logs:
    ```bash
    journalctl -b 0 --user-unit=init
    # Or check GDM login daemon outputs
    journalctl -u gdm
    ```
