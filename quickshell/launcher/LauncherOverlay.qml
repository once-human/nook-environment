import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

ShellWindow {
    id: window

    // Wayland layer-shell protocol layout bindings
    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }
    
    // Position at Overlay layer to capture keyboard focus cleanly
    exclusionMode: ExclusionMode.None
    layer: LayerShell.Overlay
    keyboardFocus: true
    color: "transparent"

    property bool active: false

    function toggle() {
        active = !active
        if (active) {
            searchField.focus = true
            searchField.text = ""
        }
    }

    // Modal background dim overlay
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "#0a0a0c"
        opacity: active ? 0.45 : 0.0
        
        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: window.toggle()
        }
    }

    // Elegant Centered Glassmorphic Modal
    Rectangle {
        id: modal
        width: 640
        height: 480
        anchors.centerIn: parent
        
        color: "#16161a"
        radius: 16
        border.color: "#ffffff1a"
        border.width: 1

        scale: active ? 1.0 : 0.95
        opacity: active ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation { duration: 200; easing.type: Easing.OutExpo }
        }
        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            // Dynamic Input Field
            TextField {
                id: searchField
                width: parent.width
                height: 48
                placeholderText: "Search apps, formulas, or system settings..."
                placeholderTextColor: "#ffffff4d"
                
                color: "#ffffff"
                font.pixelSize: 16
                
                background: Rectangle {
                    color: "#ffffff0a"
                    radius: 8
                    border.color: searchField.activeFocus ? "#ffffff33" : "#ffffff0d"
                    border.width: 1
                }
                
                onAccepted: {
                    console.log("[Launcher] Executing search query: " + text)
                    window.toggle()
                }
            }

            // Results List Placeholder
            ListView {
                width: parent.width
                height: parent.height - 80
                spacing: 8
                clip: true

                model: [
                    { name: "Visual Studio Code", desc: "Development Environment" },
                    { name: "Kitty Terminal", desc: "GPU Accelerated Terminal" },
                    { name: "Zen Browser", desc: "Web Browser" },
                    { name: "System Monitor", desc: "Task Manager" }
                ]

                delegate: Rectangle {
                    width: parent.width
                    height: 56
                    color: mouseArea.containsMouse ? "#ffffff0a" : "transparent"
                    radius: 8
                    
                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 16

                        // App Icon placeholder
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 6
                            color: "#ffffff12"
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: modelData.name
                                color: "#ffffff"
                                font.weight: Text.Medium
                                font.pixelSize: 14
                            }
                            Text {
                                text: modelData.desc
                                color: "#ffffff7f"
                                font.pixelSize: 11
                            }
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            console.log("[Launcher] Launching app: " + modelData.name)
                            window.toggle()
                        }
                    }
                }
            }
        }
    }
}
