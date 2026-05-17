# IPC and Shell Interaction Models

This document examines the interaction models of the host desktop environment, focusing on the Super key release toggle-interrupt state machine and bi-directional IPC channels.

---

## 1. The Super-Release Toggle-Interrupt State Machine

In desktop shell design, one of the most difficult interactions to refine is the behavior of the primary modifier key (`Super` / `Meta`). In commercial systems, pressing and releasing `Super` alone toggles the application launcher. However, if the user holds `Super` and presses other keys (e.g., `Super + Return` to launch a terminal, or `Super + Q` to close a window), the launcher must **NOT** open when `Super` is released.

To achieve this high-fidelity interaction, the current system implements a **State Machine** built on top of compositor keybinds and shell global events:

```mermaid
stateDiagram-v2
    [*] --> Idle
    
    Idle --> SuperPressed : Press Super_L
    note right of SuperPressed: Flag: launchRequested = true
    
    SuperPressed --> Interrupted : Press ANY other key / mouse click (Super + Key)
    note right of Interrupted: Flag: launchRequested = false
    
    SuperPressed --> ToggleLauncher : Release Super_L (No other keys pressed)
    note right of ToggleLauncher: Trigger Launcher UI
    
    Interrupted --> Idle : Release Super_L
    ToggleLauncher --> Idle : Close Launcher / Lose Focus
```

### The Keybind Configuration
The implementation uses specialized Hyprland keybind flags:

```ini
# 1. Listen for Left Super release to toggle the search screen
bindid = Super, Super_L, Toggle search, global, quickshell:searchToggleRelease

# 2. Intercept ANY other keypress while Super is held to cancel the search toggle
binditn = Super, catchall, global, quickshell:searchToggleReleaseInterrupt

# 3. Intercept mouse clicks and scrolls while Super is held to cancel
bind = Super, mouse:272, global, quickshell:searchToggleReleaseInterrupt
bind = Super, mouse:273, global, quickshell:searchToggleReleaseInterrupt
bind = Super, mouse_up,  global, quickshell:searchToggleReleaseInterrupt
bind = Super, mouse_down,global, quickshell:searchToggleReleaseInterrupt
```

### How the Mechanics Work
1.  **Pressing Super**: Hyprland registers the initial modifier hold. The shell raises a temporary Boolean flag `launchRequested = true`.
2.  **Catchall Interruption**: If the user presses any other key (e.g., `Tab` to navigate, `Q` to close, or clicks/scrolls the mouse), the catchall rule `binditn = Super, catchall` triggers, executing `quickshell:searchToggleReleaseInterrupt`. This instantly flips `launchRequested` to `false`.
3.  **Key Release**: When `Super_L` is released, the shell checks `launchRequested`. If it remains `true`, it toggles the search window. If it is `false` (due to interruption), the event is silently ignored. This prevents the launcher from popping up on modifier release.

---

## 2. Bi-Directional IPC Communication Channels

Communication inside the desktop environment is split into downstream event broadcasts and upstream command executions.

### Downstream (Compositor/System to Shell)
1.  **Compositor Event Pipe**: The compositor broadcasts low-level window actions via `.socket2.sock`. The shell parses events (e.g., `activewindow>>code,Visual Studio Code`) to update dynamic properties like the active task icon.
2.  **System Event Monitors**: D-Bus and Udev pipe hardware signals (e.g., power adapter connections, bluetooth pairing, network interface status changes) directly into shell singletons.

### Upstream (Shell to Compositor/System)
1.  **Direct Dispatcher Execution**: When the user clicks visual panels (e.g., clicking a workspace card in the overview, or selecting "Lock" in the session menu), the shell executes compositor commands directly:
    ```js
    Quickshell.execDetached(["hyprctl", "dispatch", "workspace", targetId])
    ```
2.  **Helper Script Delegations**: For operations requiring elevated privileges or heavy logic (e.g., recording screen output, switching wallpapers, or applying Matugen themes), the shell delegates tasks to specialized background scripts (e.g., `record.sh`, `switchwall.sh`) to prevent blocking the UI event loop.
