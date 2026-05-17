# Nook Shell System Architecture
## Multi-Layer System Design for High-Performance Workspaces

Nook Shell utilizes a highly decoupled, multi-layered architecture designed to achieve zero-latency desktop interaction, deep system integration, and adaptive workspace orchestration. 

```
┌─────────────────────────────────────────────────────────┐
│              Presentation Layer (Flutter)               │
│  - Panels, Sidebars, App Launchers, Workspace Overview  │
└───────────────────────────▲─────────────────────────────┘
                            │ IPC (JSON / Unix Sockets)
┌───────────────────────────▼─────────────────────────────┐
│             Shell Daemon Layer (Rust: nookd)            │
│  - State Orchestration   - Context Engines  - System DB │
│  - Session Memory        - IPC Handlers     - Services  │
└───────────────────────────▲─────────────────────────────┘
                            │ Socket / hyprctl IPC
┌───────────────────────────▼─────────────────────────────┐
│                 Compositor Layer (Hyprland)             │
│  - Window Management   - Input Handling  - Layout Grids │
└─────────────────────────────────────────────────────────┘
```

---

## 1. Architectural Layers

### A. Compositor Layer (Hyprland / Wayland)
The compositor handles window layout, tiling, physical input translation, hardware rendering, and Wayland seat states.
* **Responsibilities**: Window placement, input routing, workspace switching, screen capture, animation rendering, and monitor scaling.
* **Integrations**: Connects to the shell via Hyprland's `socket1` (command execution) and `socket2` (real-time raw event broadcast).

### B. Shell Daemon Layer (`nookd` - Rust)
The central intelligence of the environment. Written in Rust for type-safety, memory safety, and native system-level speed.
* **Responsibilities**: Monitors active windows, tracks workspace state changes, performs low-overhead system monitoring (RAM, CPU, Audio, Brightness, Network), maintains active task context databases, and operates the local workspace state cache.
* **Performance Control**: Spawns light background threads to process heavy data operations, ensuring the user interface remains at an uninterrupted 120Hz/144Hz render loop.

### C. Presentation Layer (`nook-shell` - Flutter)
The visual representation layer. Built using Flutter for performance-native canvas rendering, smooth 60fps+ desktop layouts, and modern typography support.
* **Responsibilities**: Displays overlays, status panels, sidebars, application menus, notification lists, and overlay workspace overview interfaces.
* **Wayland Layer Integration**: Utilizes Wayland's `layer-shell` protocol to register window surfaces with the correct layering rules (e.g. status bar at `top`, full overlays at `overlay`, and desktop indicators at `bottom`).

---

## 2. IPC & Communication Layer

To prevent CPU spikes and event bottlenecks, the system leverages a structured IPC pipeline:
1. **Hyprland Event Listener**: The `nookd` Rust daemon listens continuously to Hyprland's `socket2` UNIX socket, catching real-time events like `activewindow`, `createworkspace`, `destroyworkspace`, or `changefloatingmode`.
2. **Internal Unix Socket**: `nookd` exposes a local, secure Unix Socket (`/run/user/$UID/nookd.sock`) for lightning-fast JSON-RPC style communication.
3. **Frontend Connection**: The presentation shell (`nook-shell`) connects directly to `nookd.sock`. When a state changes (e.g., active window shift), `nookd` pushes a lightweight, structured JSON payload to the presentation layer, instantly updating the UI with near-zero latency.

---

## 3. Service Layer

The environment breaks down system interactions into highly specialized, isolated service modules:
* **Audio & Brightness Services**: Connects directly to PipeWire/WirePlumber and `sysfs` brightness nodes. Instead of launching heavy subprocesses like `pamixer` or `light` on every adjust, `nookd` interacts directly with libraries/system nodes for instant latency-free feedback.
* **Bluetooth & Network Services**: Connects to SystemD DBus APIs (`bluez` and `NetworkManager`) to read connection speeds, device lists, and power configurations asynchronously.
* **Process & Window Services**: Maintains an indexed list of active window identifiers, classes, and titles, enabling the UI to render active window indicators instantly without parsing raw text feeds on every tick.

---

## 4. Adaptive & Memory Layer (Cognitive Engine)

The cognitive layer transforms Nook Shell from a static window manager into a stateful extension of the developer's mind.

### A. Context Tracking
The `nookd` daemon monitors:
* **Active Projects**: Looks at the active workspace's window processes (e.g. terminal current working directory, open VS Code or Cursor projects, active Git repo).
* **Work Activity**: Groups workspace contexts dynamically by analyzing directory hierarchies, git commit patterns, and active compilers.
* **Temporal Patterns**: Learns times and days when specific workflows are run.

### B. Adaptive Launcher & UI
Based on the tracked context, Nook Shell adapts without being intrusive:
* **Dynamic Search Indexing**: When opening the application launcher (`SUPER + SPACE`) in a "development" workspace, development utilities, active repositories, and terminal tasks are automatically prioritized at the top of the search stack.
* **Sidebar Adjustments**: Quick-toggle modules and terminal actions adjust to match the active project context (e.g., displaying Docker actions when in a backend workspace, or Flutter controls when in a frontend workspace).

### C. Future Memory & Context Systems
As the system evolves, Nook Shell will feature a local, lightweight vector database or key-value memory system (`nookd/src/memory.rs`). This enables **Workspace Resumption**:
* **Workspace Stashing**: Stashes workspace states (such as active working directories, terminal logs, editor files, layout positions) when closing a workflow workspace.
* **Re-anchoring**: Automatically restores project nodes, opens relevant tools, and sets the compositor layout when returning to that workspace—completely avoiding cognitive setup friction.
