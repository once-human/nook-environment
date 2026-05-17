# Research: Hyprland Compositor IPC & Responsibilities
## Sockets, Streams, and the Clean Decoupling of Shell vs Compositor

This document defines the interface standards, IPC pipes, and conceptual segregation between the compositor engine and the Nook Shell runtime.

---

## 1. Hyprland IPC Interfaces

Hyprland provides two distinct UNIX domain sockets inside the runtime directory (`/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/`):

### A. Socket 1 (Command Dispatcher)
* **File Name**: `.socket.sock`
* **Mode**: Read/Write (Request-Response)
* **Usage**: Accepts command strings (e.g., `dispatch workspace 2`, `keyword decoration:rounding 12`) and returns plain text execution confirmations or structured JSON reports.
* **Nook Integration**: `nookd` uses Socket 1 to dispatch explicit window management actions, trigger layout adjustments, or queries monitored boundaries.

### B. Socket 2 (Event Stream Broadcast)
* **File Name**: `.socket2.sock`
* **Mode**: Read-Only (Continuous Broadcast Stream)
* **Usage**: Emits newline-terminated event lines in real-time on every compositor state change:
  ```
  workspace>>2
  activewindowv2>>0x628fb125ab30,kitty,Alacritty
  fullscreen>>0
  focusedmon>>DP-1
  ```
* **Nook Integration**: `nookd` spawns an asynchronous UNIX stream listener on Socket 2, passing lines into a lightweight Rust parser to update internal workspace contexts.

---

## 2. Decoupling Responsibilities

A key failure of heavy desktop environments is the tight coupling of compositor logic with visual widgets. Nook Shell enforces a strict boundary of concerns:

| Layer / Concerns | Compositor Responsibilities (Hyprland) | Shell Responsibilities (Nook Shell / nookd) |
|------------------|----------------------------------------|---------------------------------------------|
| **Window Layout**| Tiling algorithms, floating nodes, resizing grids | Overlay management (bars, panels, overview HUDs) |
| **Input Routing**| Physical keyboard/mouse grabs, touchpad swipe mapping | Shortcut hooks, virtual actions, task context |
| **System State** | Monitors, resolutions, seat allocations | CPU metrics, memory caches, volume/brightness |
| **Metadata DB**  | Purely processes active windows and PIDs | Session history, vector context, Git indices |
| **Rendering**    | Hardware outputs, frame synchronization | Layer-shell widgets, canvas rendering |

### Why this division is critical:
* **Stability**: If the visual shell (`nook-shell` or Flutter frontend) crashes or reloads, the active window compositor (Hyprland) remains completely active and stable. No client processes are lost; windows never reset.
* **Performance**: The compositor handles high-performance graphics and window positioning. Visual overlay managers only render when changes are committed, reducing overall graphics pipeline bottlenecks.

---

## 3. Async Socket Listener Implementation

The `nookd` daemon implements Socket 2 event streaming using tokio's asynchronous UNIX socket libraries in Rust:

```rust
use tokio::net::UnixStream;
use tokio::io::{AsyncBufReadExt, BufReader};

pub async fn start_event_loop(socket_path: &str) -> Result<(), Box<dyn std::error::Error>> {
    let stream = UnixStream::connect(socket_path).await?;
    let mut reader = BufReader::new(stream).lines();

    while let Some(line) = reader.next_line().await? {
        parse_compositor_event(&line);
    }
    Ok(())
}

fn parse_compositor_event(event: &str) {
    if let Some((event_name, data)) = event.split_once(">>") {
        match event_name {
            "workspace" => handle_workspace_change(data),
            "activewindowv2" => handle_active_window(data),
            _ => {}
        }
    }
}
```

This ensures that the compositor event stream is processed concurrently, maintaining incredibly low latency profiles while generating JSON events for the presentation layer.
