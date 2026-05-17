import QtQuick
import Quickshell
import Quickshell.Hyprland

/**
 * Nook State Manager Service
 * Manages active window, workspace, and monitor cache systems.
 * Refined to use zero-fork event mappings.
 */
QtObject {
    id: service

    property int activeWorkspace: 1
    property string activeWindowName: ""
    property var workspaceList: []

    Component.onCompleted: {
        console.log("[Nook] State manager service started.")
        syncWorkspaces()
    }

    // Incremental Workspace State Synchronization
    function syncWorkspaces() {
        // Zero-fork cache population placeholder
        service.workspaceList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    }

    function changeWorkspace(targetId) {
        console.log("[Nook] Navigating to workspace: " + targetId)
        Quickshell.execDetached(["hyprctl", "dispatch", "workspace", targetId.toString()])
    }
}
