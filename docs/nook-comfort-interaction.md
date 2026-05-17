# Nook Comfort & Interaction Specification

This document defines how **Nook Shell** inherits, refines, and rebuilds the desktop interaction systems from the daily-driver environment, establishing a highly polished, ergonomic, and premium desktop experience.

---

## 1. Concept Mappings: Inherited vs. Redesigned

Rather than duplicating the Illogical Impulse profile verbatim, Nook systematically extracts its core usability principles and redesigns their technical implementations to ensure absolute performance and stability.

```
                  ┌──────────────────────────────────────────┐
                  │    Host Setup (Illogical Impulse)        │
                  └────────────────────┬─────────────────────┘
                                       │
                     Selective Concept │ Extraction
                                       ▼
                  ┌──────────────────────────────────────────┐
                  │              Nook Shell                  │
                  └─────┬──────────────────────────────┬─────┘
                        │                              │
       Inherited        ▼                              ▼  Redesigned
  ┌───────────────────────────┐         ┌───────────────────────────────┐
  │  Resilient Fallbacks      │         │ Zero-Fork IPC Daemon          │
  │  Super Release Interrupts │         │ Strict Module Encapsulation   │
  │  Paginated Workspace Grid │         │ Clean, Fluid Animation Curves │
  └───────────────────────────┘         └───────────────────────────────┘
```

### Concepts Conceptualized & Inherited
1.  **Symmetrical Fallback Model**: Composite binds probe the Shell Layer's active status via a fast handshake query (`TEST_ALIVE`). If the high-level shell runtime is unresponsive, the compositor instantly routes commands to simple standalone CLI utilities (`wofi`, `fuzzel`, `grim`), preventing desktop locks.
2.  **Left-Super Release Interrupts**: Modifier-release triggers intercept keystrokes dynamically. Pressing `Super` alone toggles the launcher on release, but using `Super` as a modifier for workspace switches or window manipulation instantly cancels the release-trigger, keeping the desktop uncluttered.
3.  **Paginated Workspace Grid**: Workspaces are organized in grid pages of ten, enabling natural multi-monitor workspace isolation and reducing scrolling distance.

### Systems Purified & Redesigned
1.  **Zero-Fork Event Cache**: The host environment spawns up to five sub-processes (`hyprctl -j`) on every single compositor event, causing micro-stutters. Nook replaces this model with a dedicated persistent daemon (`nookd`) that maintains an in-memory client tree, updating incrementally via Unix socket signals and exposing state instantly to QML.
2.  **Strict UI Encapsulation**: Dynamic visual widgets are built as clean, standalone QML files in a dedicated `quickshell/` workspace, entirely separate from system automation scripts, reducing maintenance overhead.
3.  **Refined Physical Aesthetics**: Animations are designed around a unified physical decel curve (`emphasizedDecel`), creating a calm, high-fidelity responsive feel without frantic visual bouncing or visual clutter.

---

## 2. Quickshell Architecture Specifications

Nook Shell utilizes a minimal, highly modular Quickshell structure designed to act as the primary desktop layer runtime:

| File Path | Responsibility | Layer Namespace |
| :--- | :--- | :--- |
| `quickshell/shell.qml` | Master QML entrypoint; orchestrates dynamic component loading, triggers services, and coordinates overlays. | *Shell Engine* |
| `quickshell/services/HyprlandData.qml` | Gathers event broadcasts from Hyprland and exposes active workspace lists and window coordinates. | *State Singleton* |
| `quickshell/launcher/LauncherOverlay.qml` | Centered modal for application and command launching. Incorporates XDG desktop indexers and fuzzy searching. | `LayerShell.Overlay` |
| `quickshell/overview/OverviewOverlay.qml` | Full-screen spatial zoom-out map showing workspaces, allowing visual sorting and drag-and-drop window movements. | `LayerShell.Overlay` |

---

## 3. Active Placeholder Systems

To ensure Nook remains highly usable and lightweight as it evolves, several non-essential layers are designed with clean system placeholders:

1.  **Volume & Brightness OSDs**: High-level visual volume meters are currently proxied via direct PipeWire (`wpctl`) and backlight (`brightnessctl`) bindings, avoiding heavy background listener loops.
2.  **System Tray (SNI)**: System tray indices are handled natively by Waybar, keeping the Quickshell runtime focused purely on the launcher, workspaces, and slide-out sidebars.
3.  **AI Assistant & Environmental Context**: Prompt contextualization and project workspace restoration are defined as standard static overlays, preparing for clean integration with `nookd` context pipelines in the future.
