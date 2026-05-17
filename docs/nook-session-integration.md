# Nook GDM Desktop Session Integration

This document defines the GDM desktop session integration model for **Nook Shell**, detailing the decoupled startup architecture, environment variables orchestration, and verification workflows.

---

## 1. Session Architectural Overview

Nook Shell behaves as a first-class, GDM-selectable Wayland desktop session. By registering Nook natively with the display manager, users can boot directly into the environment without affecting standard GNOME or stock Hyprland/Illogical Impulse sessions.

```
       ┌────────────────────────┐
       │   GDM Display Manager  │
       └───────────┬────────────┘
                   │
  Reads session    │ installs template to
  Desktop Entry    ▼ /usr/share/wayland-sessions/nook-shell.desktop
       ┌────────────────────────┐
       │      nook-session      │
       └───────────┬────────────┘
                   │
  Launches wrapper │ exports parameters, boots nookd daemon,
  script binary    ▼ & executes isolated compositor
       ┌────────────────────────┐
       │   Hyprland Compositor  │
       └────────────────────────┘
         (Sourced strictly from ~/.config/nook/hypr/hyprland.conf)
```

---

## 2. Desktop Launch Sequence & Environment Isolation

When a user selects **Nook Shell** at login, GDM coordinates the boot flow using a multi-step sequence to guarantee absolute state isolation:

### Step 1: Entry Parsing
GDM reads `/usr/share/wayland-sessions/nook-shell.desktop`. The desktop entry specifies:
*   `Exec=nook-session`: Calls the dedicated session wrapper script.
*   `DesktopNames=Nook`: Flags the current shell namespace for desktop portals.

### Step 2: Environment Initialization
The wrapper script `/usr/local/bin/nook-session` executes, performing clean environment setups:
1.  **Desktop Boundaries**: Exports `XDG_CURRENT_DESKTOP=Nook` and `XDG_SESSION_DESKTOP=Nook` to allow XDG desktop portals to route windows and shortcuts under Nook metrics.
2.  **Wayland Support**: Binds graphics backend parameters (`GDK_BACKEND=wayland`, `QT_QPA_PLATFORM=wayland`, `SDL_VIDEODRIVER=wayland`) to force applications to run natively in Wayland rather than falling back to X11 emulation.
3.  **Background Services**: Detects if the Rust systems daemon (`nookd`) is present and spawns it in the background to handle context/timeline calculations.

### Step 3: Compositor Sourcing
The session script launches Hyprland isolated:
```bash
exec Hyprland --config "${HOME}/.config/nook/hypr/hyprland.conf"
```
By explicitly loading the configuration from `~/.config/nook/hypr/hyprland.conf` rather than stock directories (`~/.config/hypr/hyprland.conf`), Hyprland runs completely isolated within Nook's modular environment. This prevents any side-effects or configuration corruption on your main, daily-driver desktop environment!

---

## 3. Template-Based Repository Design

To adhere to strict software packaging and engineering guidelines, **Nook Shell does not mirror the full Linux system filesystem** inside the development repository.

### Why Templates are Kept in the Repository:
1.  **Sandboxing & Isolation**: Creating system-level files directly inside the repository would pollute Git logs and lead to hardcoded environment assumptions that vary across distributions.
2.  **Distribution Portability**: Storing files as decoupled templates allows the integration files to be easily packaged by Arch PKGBUILDs, Debian packages, or Nix derivations in the future.
3.  **Permissions Protection**: Restricting GDM configuration writes to an explicit installer script (`install.sh`) ensures that modifications to system-level directories (`/usr/share/`, `/usr/bin/`) require active user consent and sudo privileges, fully preserving system integrity.

---

## 4. Manual Installation & Verification

To install the integration files from your local workspace, navigate to the packaging directory and execute the coordinator:

```bash
cd ~/Documents/Projects/nook-environment/packaging/scripts
chmod +x install.sh
./install.sh
```

### Script Execution Parameters:
*   Checks for elevated privileges and verifies that source files exist.
*   Backs up pre-existing versions of `/usr/share/wayland-sessions/nook-shell.desktop` and `/usr/local/bin/nook-session` using timestamp suffixes.
*   Copies the session entry, installs the wrapper script, and configures appropriate permissions (+x).
*   Enables instant selection at the GDM lockscreen.
