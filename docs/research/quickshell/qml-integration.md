# Research: Quickshell Integration & Decoupling Models
## State Singletons, Process-Spawning Bottlenecks, and the Rust-Flutter Paradigm

This document studies the QML integration models in **Quickshell**, detailing the active state synchronization architecture and the performance trade-offs that led to the Rust + Flutter design of Nook Shell.

---

## 1. Analysis of Quickshell Integration Patterns

Quickshell is a declarative Wayland shell engine that uses QtQuick/QML. Its architecture relies heavily on:
* **The ShellRoot Entrypoint**: Integrates layout and panel loading.
* **Singleton State Management**: A centralized singleton (`GlobalStates.qml`) containing properties like `sidebarLeftOpen`, `overlayOpen`, `overviewOpen`, and `screenLocked`. Every module binds directly to these states, triggering slide-in/fade transitions declaratively when they switch.
* **Event Sourcing**: Listens to raw events from the compositor via `Quickshell.Hyprland` integrations to drive interface updates.

---

## 2. The Process-Spawning Bottleneck

While Quickshell renders layouts smoothly, extracting advanced system and compositor states introduces massive structural friction. 

### The Problem (`HyprlandData.qml`):
To retrieve active window addresses, layout coordinates, monitors, and layers, Quickshell must execute shell processes asynchronously:
```qml
Process {
    id: getClients
    command: ["hyprctl", "clients", "-j"]
    stdout: StdioCollector {
        onStreamFinished: {
            root.windowList = JSON.parse(clientsCollector.text);
        }
    }
}
```
* **Performance Impact**: Every time a window opens, closes, focus shifts, or layouts reload, the shell must spawn `hyprctl clients -j`, `hyprctl monitors -j`, and `hyprctl workspaces -j` subprocesses.
* **CPU and Latency Overhead**: Spawning subprocesses, collecting stdout, and parsing large JSON outputs in JavaScript is incredibly CPU-intensive. During fast workspace swaps or intensive tiling actions, this process spawning leads to frame-drops, micro-stutters, and input lag.

---

## 3. The Nook Shell Decoupling Solution (Rust + Flutter)

Nook Shell solves this bottleneck by decoupling **System State Orchestration** from the **Presentation Layer**:

```
 ┌────────────────────────────────────────────────────────┐
 │                      nook-shell (UI)                   │
 │  - Renders panels at 120Hz using Flutter/Impeller.     │
 │  - Zero subprocess spawning or direct sysfs parsing.   │
 └───────────────────────────▲────────────────────────────┘
                             │ JSON-RPC Unix Socket
 ┌───────────────────────────▼────────────────────────────┐
 │                       nookd (Daemon)                   │
 │  - Listens directly to Hyprland UNIX socket2 events.   │
 │  - Compiles state lists natively in a background.      │
 │  - Direct C/Rust library bindings for Audio & CPU.     │
 └────────────────────────────────────────────────────────┘
```

### Key Innovations:
1. **Zero Subprocesses**: The Rust daemon (`nookd`) connects to Hyprland's UNIX sockets directly. Instead of executing shell commands, it parses incoming compositor events instantly in a compiled native thread, maintaining a lightweight in-memory workspace database.
2. **System Library Bindings**: `nookd` communicates with Pipewire/Alsa or sysfs nodes via direct library calls rather than running utility binaries (like `pamixer` or `light`).
3. **Decoupled Render Pipeline**: The Flutter frontend (`nook-shell`) remains absolutely lightweight. It receives clean, processed JSON states via a local Unix socket. It never parses logs, queries hardware, or scrapes window statistics directly—resulting in zero micro-stutters and rock-solid 144Hz animation loops.
4. **Declarative State Singletons**: The Flutter frontend mirrors Quickshell's successful declarative state singleton model using clean state management paradigms, allowing windows and overlays to transition in and out cleanly.
