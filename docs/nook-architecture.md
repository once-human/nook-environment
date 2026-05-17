# Nook Shell Architecture Specification

This document details the multi-layered system architecture for **Nook Shell**. Nook is designed with clean separation of concerns, high performance, and absolute system resilience at its core.

```mermaid
graph TD
    subgraph Compositor Layer [Compositor Layer (Hyprland)]
        hc[hyprland.conf] --> he[execs.conf / keybinds.conf / rules.conf]
        he --> hso[shellOverrides/main.conf]
    end

    subgraph IPC Layer [IPC Layer]
        us[Hyprland Socket2] <--> sb[Bi-directional Event Bus]
        ch[CLI Command Handler] <--> sb
    end

    subgraph Shell Layer [Shell Layer (Wayland Layer-Shell)]
        sb <--> qsr[Shell Entrypoint]
        qsr --> qpl[UI Component Panels / Bars / Sidebars / Overlays]
    end

    subgraph Service Layer [Service Layer]
        qsr --> se[XDG App Indexer]
        qsr --> ae[Mpris / Audio / Brightness]
        qsr --> ne[Network / Bluetooth / Power]
    end

    subgraph Adaptive Systems Layer [Adaptive Systems Layer]
        se --> ws[Work Safety Context Monitor]
        qpl --> wge[Window Geometry Evaluator]
        qpl --> fwc[Focused Window Context Pass]
    end

    subgraph Memory & Context Layer [Memory & Context Layer]
        fwc --> fme[Local SQLite / Vector Memory Engine]
    end

    classDef layer fill:#2d3748,stroke:#4a5568,color:#fff;
    class hc,he,hso,us,sb,ch,qsr,qpl,se,ae,ne,ws,wge,fwc,fme layer;
```

---

## 1. The Compositor Layer (Hyprland)

The Compositor Layer sits at the lowest level of the shell platform. It is responsible for window management, graphics composition, input device routing, and initial keybinding interception.

*   **Modular Configurations**: Hyprland configurations are separated into distinct domain files under `~/.config/hypr/hyprland/` (e.g., `keybinds.conf`, `rules.conf`, `execs.conf`) and mirrored in `custom/` directories to allow non-destructive user modifications.
*   **Cascading Overrides**: At the very end of the main `hyprland.conf`, the compositor sources a designated override file:
    ```ini
    source = hyprland/shellOverrides/main.conf
    ```
    This file acts as a dynamic state buffer. The Shell Layer can write parameters directly into this file at runtime (e.g., changing border radius, window gaps, layout modes) and trigger a compositor reload, ensuring a highly responsive, dynamic shell experience without hardcoding values in main files.

---

## 2. The IPC Layer (Communication Fabric)

The IPC Layer provides bi-directional event distribution and command routing between the Compositor, the Shell Layer, and external command line tools.

*   **Hyprland Event Socket**: The IPC Layer connects to Hyprland's native Unix socket (`.socket2.sock`) to receive real-time compositor events (e.g., `workspace`, `activewindow`, `openwindow`, `closewindow`).
*   **CLI Command Handler**: External inputs (such as terminal scripts, cron jobs, or specialized keybinds) communicate with the running shell via a standardized CLI binary.
*   **Tiered Fallback Mechanism**: To ensure absolute resilience, keyboard and system triggers are engineered with fallback chains. Keybinds do not blindly assume the Shell Layer is running. Instead, they probe the shell's active state using a lightweight handshake:
    ```ini
    bind = Super, Super_L, exec, qs ipc call TEST_ALIVE || pkill fuzzel || fuzzel
    ```
    If the sophisticated Shell Layer is alive, the shell interceptor catches the event. If the shell has crashed or is not loaded, the compositor immediately falls back to launching a lightweight standalone tool (`fuzzel` for launcher, `grim` for screenshots, `wlogout` for session management).

---

## 3. The Shell Layer (UI Runtime)

The Shell Layer is responsible for drawing widgets, panels, and layouts adhering strictly to the Wayland **Layer-Shell Protocol**.

*   **Entrypoint (`shell.qml`)**: Initializes core engines, registers global shortcut hooks, and handles active dynamic panel families (e.g., standard layout versus clean dashboard overlays).
*   **Sub-Layer Routing**: Elements are mapped to Wayland Layer-Shell namespaces:
    *   *Background/Bottom*: Desktop wallpaper, least-busy system widgets (clocks).
    *   *Top*: Status bars, system docks, active sidebars.
    *   *Overlay*: Launcher screens, notifications, critical session alerts, dynamic cheatsheets.
*   **UI Components**: Written as modular QML files utilizing modern typography, HSL-tailored colors, and GPU-accelerated graphics styling (e.g., glassmorphism, rounded corners, soft shadows).

---

## 4. The Service Layer

The Service Layer runs background singletons within the shell process to track state, build indexes, and control physical resources.

*   **XDG Application Indexer**: Natively parses Linux `.desktop` files, watches directories for updates, and indexes applications with fzf-like fuzzy matching support.
*   **MPRIS & Audio/Brightness Service**: Monitors media players, volume channels (via WirePlumber/PipeWire), and screen backlights (via `brightnessctl` or hardware interfaces), updating shell properties reactively.
*   **System Monitors**: Gathers network configurations, bluetooth interfaces, battery metrics, and Polkit authentication requests, abstracting them into structured reactive properties for the UI.

---

## 5. The Adaptive Systems Layer

The Adaptive Systems Layer provides context-aware capabilities without sacrificing user agency or introducing AI hype.

*   **Work Safety Context Monitor**: Watches physical context metrics, such as the active network SSID. If the network contains keywords (e.g., "public", "school", "office"), the monitor automatically adjusts content censorship parameters, hiding private widgets, local wallpapers, or visual notifications.
*   **Window Geometry Evaluator (Least-Busy Placement)**: Dynamically checks active client window locations and dimensions. Overlaid desktop widgets (such as the analog clock or system status dials) are positioned dynamically in coordinate grids that contain the least window density, preventing overlapping visual noise.
*   **Focused Window Context Passer**: Extracts the focused window class name (e.g., `code`, `kitty`, `browser`) and projects it as an active context parameter. The shell utilizes this to tailor tools, launcher shortcuts, or helper panels specifically to the active application.

---

## 6. The Memory and Context Layer (Future Expansion)

The Memory Layer provides long-term local state tracking to support professional developers and system power users.

*   **Local Vector/SQLite Memory Engine**: A lightweight, zero-latency local database that logs historical interactions, frequent commands, active project directories, and workspace states.
*   **Predictive Context Engine**: By correlating the current physical time, active workspace layout, and developer directories, the shell can automatically reconstruct specialized environments (e.g., opening custom code workspaces, launching specific dev servers, and adjusting screen settings automatically when the user initiates a specific task category).
*   **Absolute Privacy**: Zero external data transit. All context modeling is processed fully local, running as lightweight C/C++ background modules to guarantee near-zero resource consumption.
