# Research: Workspace Orchestration Patterns
## Dynamic Life-cycles, Touchpad Swipe Gestures, and Active Window Focus

This document explores how workspaces are managed, navigated, and tracked in high-performance tiling compositors, detailing optimization metrics for Nook Shell.

---

## 1. Dynamic Workspace Lifecycle

In stock Hyprland, workspaces are completely dynamic. They do not occupy static memory regions when empty; they are:
1. **Created on-demand** when a window is spawned on or migrated to a workspace ID.
2. **Destroyed instantly** when the last active window on that workspace is closed or moved.

### Event Propagation Triggers:
When workspaces scale, Socket 2 broadcasts event triggers:
* `createworkspace>>[ID]`
* `destroyworkspace>>[ID]`
* `movewindow>>[Address],[WorkspaceID]`

### The Focus Tracking Problem:
A common shell lag occurs when the visual bar panel struggles to update its "occupied" workspace indicators. If the shell relies on spawning `hyprctl workspaces` on every window open/close, the panel indicators will lag several frames behind the actual visual shift.

---

## 2. Swipe Gestures & Animation Latency

Hyprland provides direct compositor-level swipe gestures:
```ini
gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
    workspace_swipe_distance = 300
}
```

### Mechanics of Swipe Transitions:
1. **Viewport Translation**: The compositor translates 3-finger horizontal touchpad motions into smooth physical translations of workspace rendering matrices.
2. **Visual Continuity**: As the viewport translates, the shell status bar must smoothly update its workspace indicators (shifting active highlights, changing button focus) in perfect sync with the swipe.
3. **The Micro-Stutter Risk**: If the status bar tries to redraw its list or execute process commands mid-swipe, the compositor graphics pipeline stalls. This drops the transition from a smooth 144Hz down to a jarring 30Hz stutter.

---

## 3. Nook Shell Workspace Orchestration Design

Nook Shell solves lifecycle and swipe latency using an in-memory **Active Workspace Stack** inside the `nookd` daemon:

```
[Compositor Socket 2 Stream]
          │
          ├─► createworkspace>>3  ──► [nookd Active Workspace Stack] ──► (In-Memory Map)
          ├─► movewindow>>...     ──► [Updates index asynchronously]  ──► (No Process Spawns)
          │                                                                      │
          └──────────────────────────────────────────────────────────────────────┴──► [JSON state pushed]
                                                                                              │
                                                                                     [nook-shell (Flutter)]
                                                                                     - Smooth animations
                                                                                     - Instant pill updates
```

### Key Orchestration Rules:
1. **Asynchronous Cache**: `nookd` maintains a clean `WorkspaceMap` (`HashMap<u32, WorkspaceState>` in Rust). The map is updated entirely on incoming UNIX socket events. No background command-line tools are run.
2. **Direct Workspace Navigation**: Workspace switches are dispatched via fast UNIX writes to Socket 1 (`dispatch workspace 3`).
3. **Interactive Swipe Hook**: During active touchpad swipes, the presentation shell (`nook-shell`) remains absolutely passive, relying entirely on compositor graphics. Once the swipe completes and the compositor fires `workspace>>[ID]`, the shell bar updates its selection marker with a fluid, lightweight 100ms fade transition.
