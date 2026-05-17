# Research: Search Launcher & Focus Grab Mappings
## Wayland Interactivity, Asynchronous Indexing, and the Zero-Lag Paradigm

This document analyzes the mechanics of overlay search launchers and application menus under Wayland, laying out performance enhancements designed for Nook Shell.

---

## 1. Wayland Keyboard Focus Grabs

In traditional X11 desktop environments, applications could arbitrarily seize focus and grab the global keyboard state using standard library calls. Under Wayland's security model, keyboard focus is strictly isolated:
* **The Layer-Shell Protocol**: Overlays (bars, launchers, sidebars) must register their surfaces with specific Wayland layer shells.
* **Keyboard Interactivity Modes**: To receive keystrokes, the launcher surface must request keyboard interactivity explicitly (`exclusive` or `on_demand` focus mode).
* **Focus Transition Delay**: When the user presses `SUPER + SPACE`, the compositor must map the window, transition the focus state, and direct key input to the text field. If the launcher is slow to initialize its visual hierarchy, keystrokes typed immediately are dropped, creating extreme user friction.

---

## 2. The Search Indexing Latency

Traditional launchers (like raw Wofi or Rofi setups) frequently suffer from startup lag because they perform file system operations on invocation:
1. They parse directories like `/usr/share/applications/` and `~/.local/share/applications/` synchronously.
2. They read dozens of `.desktop` files, parsing localization keys, action commands, and icon names.
3. They reconstruct the search index in memory.

Executing this system disk-scrape synchronously on invocation leads to a noticeable delay (100ms - 300ms) before the window appears, violating the calm computing principles of Nook Shell.

---

## 3. Nook Shell Decoupled Search Architecture

Nook Shell achieves an instantaneous launch experience by isolating the search index database from the user interface:

```
[System Startup]
   │
   ▼
[nookd background thread] ──► Asynchronously crawls /usr/share/applications
   │                       ──► Parses .desktop files
   │                       ──► Stores optimized JSON app database in memory
   ▼
[User presses SUPER + SPACE]
   │
   ▼
[nook-shell (Flutter overlay)] ──► Renders instantly (uses pre-loaded empty state)
                               ──► Grabs keyboard focus via layer-shell
                               ──► User type events sent to nookd via Unix socket
                               ──► Asynchronous matching search results returned in <1ms
```

### Core Launcher Rules:
1. **Background Index Caching**: The Rust `nookd` daemon parses and indexes system applications *once* at startup. It utilizes an optimized in-memory Trie structure to provide sub-millisecond prefix searches.
2. **File System Watchers**: `nookd` monitors application directories asynchronously using system inotify handlers (`notify` crate in Rust). If a package is installed or removed, the search cache is rebuilt quietly in the background without affecting active session performance.
3. **Instant Surface Mapping**: The `nook-shell` Flutter overlay launcher maintains its window in a hidden layer-shell state, or loads its visual hierarchy instantaneously using pre-cached widgets. When called, it simply requests mapping and keyboard focus grab—instantly showing up on the user's screen.
4. **Adaptive Priority**: In dev workspaces, development utilities, recently used CLI scripts, and active Git project folders are automatically boosted to the top of the query list, saving key steps.
