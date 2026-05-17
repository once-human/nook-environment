//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "services"
import "launcher"
import "overview"

ShellRoot {
    id: root

    Component.onCompleted: {
        console.log("[Nook] Quickshell engine initialized successfully.")
    }

    // --- Core UI Overlays ---
    LauncherOverlay {
        id: launcherOverlay
    }

    OverviewOverlay {
        id: overviewOverlay
    }

    // --- Bi-directional IPC Triggers ---
    IpcHandler {
        target: "nook"

        function toggleLauncher(): void {
            launcherOverlay.toggle()
        }

        function toggleOverview(): void {
            overviewOverlay.toggle()
        }
        
        function ping(): string {
            return "ALIVE"
        }
    }

    // --- Global Compositor Keybind Interceptors ---
    GlobalShortcut {
        name: "nookLauncherToggle"
        onPressed: launcherOverlay.toggle()
    }

    GlobalShortcut {
        name: "nookOverviewToggle"
        onPressed: overviewOverlay.toggle()
    }
}
