# Nook Shell Development & Live Testing Workflow

This manual covers the active engineering loop for editing, testing, and debugging the Nook Shell desktop environment and compositor engine.

---

## Live Edit Loop

Because the directory `~/.config/nook` is symlinked directly to your workspace repository `~/Documents/Projects/nook-environment`, your development changes are instantly available.

1. **Edit**: Open any configuration file in your workspace (e.g. `hypr/appearance.conf` or `waybar/style.css`).
2. **Save**: Save your file inside the editor.
3. **Hot-Reload**: Execute `nook-reload` (or run `~/.config/nook/scripts/nook-reload.sh`) to instantly load the changes into your active session.

---

## Integration with Nook Shell Daemon (`nookd`)

Your sibling workspace repository `~/Documents/Projects/nook-shell/` containing the `nookd` Rust-based compositor daemon works hand-in-hand with this configuration.

### Compilation & Execution
To compile and test the Rust daemon with the environment, use the custom developer shell aliases:

* **Compile the Daemon**:
  ```bash
  nook-build
  ```
  This runs `cargo build` on the sibling `nookd` source files.

* **Run/Test the Compositor**:
  ```bash
  nook-run
  ```
  Launches `cargo run` inside the active shell for fast feedback.

---

## System Debugging & Logs

When developing new layouts or debugging shell behaviors, use the following resources:

### Compositor Logs
Compositor stdout, standard errors, and Wayland notifications are routed directly:
```bash
nook-logs
```
This automatically tails your active session log or pulls Hyprland compositor logs via `journalctl`.

### Waybar Syntax Verification
If Waybar fails to start after editing `waybar/config.jsonc`, manually start it in a terminal to inspect the JSON parser errors:
```bash
waybar -c ~/.config/nook/waybar/config.jsonc -s ~/.config/nook/waybar/style.css
```
Common issues include trailing commas, which are invalid in strict JSON format.

---

## Development Guidelines

To maintain modularity and system-level restraint, keep to these rules:

1. **Maintain Decoupling**: Never hardcode absolute system paths in configs. Always use relative or user-relative (`~/.config/nook/...`) paths.
2. **Keyboard-First Design**: Add mouse clicks as an extension, but ensure all shell modules are fully navigable and interactive via hotkeys.
3. **No Bloat**: Avoid loading redundant system daemons. Keep startup scripts limited to bar panels, wall managers, and gestural drivers.
4. **Clean Commits**: Ensure local modifications like runtime `nook.log` or temporary system backups never pollute git history. Run `git status` to verify before staging.
