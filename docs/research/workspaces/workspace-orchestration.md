# Workspace Orchestration Patterns

This document analyzes the workspace management models of the host environment, including paginated navigation mathematics, window routing mechanics, and overview zoom-out layouts.

---

## 1. Paginated Workspace Mathematics

Hyprland natively supports an infinite flat workspace layout. To make this manageable for power users, the environment implements a **Paginated Workspace Grid** model. Rather than scrolling through an endless list of numeric indices, workspaces are segmented into groups of ten (representing individual "pages").

Navigation within these pages is managed via a dedicated bash script: `~/.config/hypr/hyprland/scripts/workspace_action.sh`.

```
           Workspace Group Page 0 (Workspaces 1 - 10)
    ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬────┐
    │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │ 8 │ 9 │ 10 │
    └───┴───┴───┴───┴───┴───┴───┴───┴───┴────┘
                        ▲
                        │ (User presses key "5" while on Page 0)
                        
           Workspace Group Page 1 (Workspaces 11 - 20)
    ┌────┬────┬────┬────┬────┬────┬────┬────┬────┬────┐
    │ 11 │ 12 │ 13 │ 14 │ 15 │ 16 │ 17 │ 18 │ 19 │ 20 │
    └────┴────┴────┴────┴────┴────┴────┴────┴────┴────┘
                        ▲
                        │ (User presses key "5" while on Page 1)
```

### The Paging Equation
When the user presses a single-digit hotkey ($1 - 10$), the orchestrator calculates the absolute target workspace index using the active workspace ID:

$$\text{Target Workspace} = \left( \left\lfloor \frac{\text{Current Workspace} - 1}{10} \right\rfloor \times 10 \right) + \text{Target Single Digit}$$

*   **Example A (Page 0)**: The user is on Workspace $3$ and presses hotkey `7`.
    $$\text{Target} = \left( \left\lfloor \frac{3 - 1}{10} \right\rfloor \times 10 \right) + 7 = (0 \times 10) + 7 = 7$$
*   **Example B (Page 1)**: The user is on Workspace $13$ and presses hotkey `7`.
    $$\text{Target} = \left( \left\lfloor \frac{13 - 1}{10} \right\rfloor \times 10 \right) + 7 = (1 \times 10) + 7 = 17$$

### Multi-Monitor Isolation
By binding separate physical monitors to their own pages (e.g., Monitor A runs Page 0 [1-10], Monitor B runs Page 1 [11-20]), pressing key `3` shifts focus to Workspace 3 on Monitor A, while pressing key `3` on Monitor B seamlessly routes to Workspace 13. This isolates monitor workspace switching and avoids confusing multi-screen swaps.

---

## 2. Dispatcher Routing Actions

The orchestrator supports distinct window and focus dispatchers:

```bash
#!/usr/bin/env bash
curr_workspace="$(hyprctl activeworkspace -j | jq -r ".id")"
dispatcher="$1" # e.g. "workspace" or "movetoworkspacesilent"
shift

if [[ "$1" =~ ^[0-9]+$ ]]; then
  target_workspace=$((((curr_workspace - 1) / 10 ) * 10 + $1))
  hyprctl dispatch "${dispatcher}" "${target_workspace}"
else
  hyprctl dispatch "${dispatcher}" "$1"
fi
```

*   **`workspace`**: Moves the user's active monitor focus instantly to the targeted paginated index.
*   **`movetoworkspacesilent`**: Sends the currently focused application window to the target workspace in the background *without* shifting the user's active viewport, allowing clean layout sorting without task interruption.

---

## 3. The Workspace Overview Zoom-Out

To help users maintain spatial awareness across their paginated grids, the shell implements a **Workspace Overview Subsystem** (triggered via `Super + Tab`).

```
┌────────────────────────────────────────────────────────┐
│  Overview Grid (0.18 Scale Layout)                    │
│                                                        │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐  │
│  │ Workspace 1   │ │ Workspace 2   │ │ Workspace 3   │  │
│  │ ┌───┐         │ │ ┌───┐  ┌───┐  │ │ (Empty)       │  │
│  │ │   │ [Active]│ │ │   │  │   │  │ │               │  │
│  │ └───┘         │ │ └───┘  └───┘  │ │               │  │
│  └───────────────┘ └───────────────┘ └───────────────┘  │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐  │
│  │ Workspace 4   │ │ Workspace 5   │ │ Workspace 6   │  │
│  │ ┌───────────┐ │ │ (Empty)       │ │ ┌───┐         │  │
│  │ │           │ │ │               │ │ │   │         │  │
│  │ └───────────┘ │ │               │ │ └───┘         │  │
│  └───────────────┘ └───────────────┘ └───────────────┘  │
└────────────────────────────────────────────────────────┘
```

### Visual and Functional Mechanics
1.  **Scale Down Composition**: On trigger, the compositor zooms out the layout by a scale factor of `0.18`, presenting active workspaces as modular tiles in a clean, uniform grid.
2.  **App Placement Serialization**: Quickshell reads window geometry data (via `HyprlandData`) and draws precise vector outlines representing active applications inside each workspace card, displaying their matched application icons.
3.  **Visual Window Manipulation**: The overview acts as an active visual control pad. Users can click workspace cards to jump directly to them, or grab application cards to drag, drop, and sort windows dynamically across workspaces.
