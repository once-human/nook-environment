import QtQuick
import Quickshell
import Quickshell.Wayland

ShellWindow {
    id: window

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    exclusionMode: ExclusionMode.None
    layer: LayerShell.Overlay
    keyboardFocus: true
    color: "transparent"

    property bool active: false

    function toggle() {
        active = !active
    }

    // Centered Visual Workspace Overview Grid Overlay
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "#070709"
        opacity: active ? 0.8 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: window.toggle()
        }
    }

    // Grid Container
    Rectangle {
        id: container
        anchors.fill: parent
        color: "transparent"
        
        opacity: active ? 1.0 : 0.0
        scale: active ? 1.0 : 1.05

        Behavior on opacity {
            NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
        }
        Behavior on scale {
            NumberAnimation { duration: 250; easing.type: Easing.OutExpo }
        }

        Column {
            anchors.centerIn: parent
            spacing: 32
            width: parent.width * 0.85

            // Heading Title
            Text {
                text: "Desktop Workspaces Overview"
                color: "#ffffffb3"
                font.pixelSize: 22
                font.weight: Text.Light
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // 10-Workspace Grid Layout
            Grid {
                columns: 5
                spacing: 16
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: 10

                    delegate: Rectangle {
                        width: 240
                        height: 135
                        color: gridMouseArea.containsMouse ? "#ffffff0d" : "#ffffff05"
                        radius: 8
                        border.color: gridMouseArea.containsMouse ? "#ffffff33" : "#ffffff1a"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 100 } }
                        Behavior on border.color { ColorAnimation { duration: 100 } }

                        Column {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            // Workspace Index number
                            Text {
                                text: (index + 1).toString()
                                color: "#ffffff"
                                font.pixelSize: 18
                                font.weight: Text.DemiBold
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            // Minimal vector representation of windows
                            Row {
                                spacing: 4
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                Rectangle { width: 32; height: 20; color: "#ffffff1f"; radius: 3 }
                                Rectangle { width: 48; height: 20; color: "#ffffff12"; radius: 3 }
                            }
                        }

                        MouseArea {
                            id: gridMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                console.log("[Overview] Navigating to workspace: " + (index + 1))
                                Quickshell.execDetached(["hyprctl", "dispatch", "workspace", (index + 1).toString()])
                                window.toggle()
                            }
                        }
                    }
                }
            }
        }
    }
}
