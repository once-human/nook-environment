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

    // Modal background dim overlay - warm sepia-charcoal wash desaturation
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "#0a3c3224" // Grounding warm neutral dim wash
        opacity: active ? 0.35 : 0.0
        
        Behavior on opacity {
            NumberAnimation { duration: 250; easing.type: Easing.OutQuint }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: window.toggle()
        }
    }

    // Centered modal container (uses absolute transparency for outer shadow layout)
    Item {
        id: modal
        width: 640
        height: 480
        anchors.centerIn: parent

        scale: active ? 1.0 : 0.985 // Symmetrical subtle Nook scaling
        opacity: active ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation { duration: 320; easing.type: Easing.OutQuint }
        }
        Behavior on opacity {
            NumberAnimation { duration: 280; easing.type: Easing.OutQuint }
        }

        // --- 1. CONTINUOUS CURVATURE MODAL SQUIRCLE CANVAS ---
        // Plots the background squircle (radius = 28px, n = 3.5) in #F6F4EF warm paper, with a quiet shadow
        Canvas {
            id: modalBgCanvas
            anchors.fill: parent
            renderTarget: Canvas.FramebufferObject

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();

                var w = width;
                var h = height;

                // Restrained Focused shadow: 0px 12px 40px rgba(46, 46, 43, 0.08)
                ctx.shadowColor = "rgba(46, 46, 43, 0.08)";
                ctx.shadowBlur = 40;
                ctx.shadowOffsetX = 0;
                ctx.shadowOffsetY = 12;

                ctx.beginPath();

                // Margins of 24px around the Canvas area to ensure shadow rendering is not clipped
                var margin = 24.0;
                var cw = w - 2 * margin;
                var ch = h - 2 * margin;
                var x = margin;
                var y = margin;

                // 28px continuous squircle curve radius (macOS window shaping)
                var r = 28.0;
                var n = 3.5; // Superellipse tension factor
                
                // Corner centers
                var cx_tr = x + cw - r;
                var cy_tr = y + r;
                
                var cx_tl = x + r;
                var cy_tl = y + r;
                
                var cx_bl = x + r;
                var cy_bl = y + ch - r;
                
                var cx_br = x + cw - r;
                var cy_br = y + ch - r;

                var steps = 16;
                var i;
                var theta;

                ctx.moveTo(cx_tl, y);
                ctx.lineTo(cx_tr, y);

                // Top-Right corner
                for (i = 0; i <= steps; i++) {
                    theta = (Math.PI / 2) * (1.0 - i / steps);
                    ctx.lineTo(cx_tr + r * Math.pow(Math.cos(theta), 2/n), cy_tr - r * Math.pow(Math.sin(theta), 2/n));
                }

                ctx.lineTo(x + cw, cy_br);

                // Bottom-Right corner
                for (i = 0; i <= steps; i++) {
                    theta = - (Math.PI / 2) * (i / steps);
                    ctx.lineTo(cx_br + r * Math.pow(Math.cos(theta), 2/n), cy_br + r * Math.pow(Math.abs(Math.sin(theta)), 2/n));
                }

                ctx.lineTo(cx_bl, y + ch);

                // Bottom-Left corner
                for (i = 0; i <= steps; i++) {
                    theta = - (Math.PI / 2) - (Math.PI / 2) * (i / steps);
                    ctx.lineTo(cx_bl - r * Math.pow(Math.abs(Math.cos(theta)), 2/n), cy_bl + r * Math.pow(Math.abs(Math.sin(theta)), 2/n));
                }

                ctx.lineTo(x, cy_tl);

                // Top-Left corner
                for (i = 0; i <= steps; i++) {
                    theta = Math.PI - (Math.PI / 2) * (i / steps);
                    ctx.lineTo(cx_tl - r * Math.pow(Math.abs(Math.cos(theta)), 2/n), cy_tl - r * Math.pow(Math.sin(theta), 2/n));
                }

                ctx.closePath();

                // Fill with primary surface Nook paper white: #F6F4EF
                ctx.fillStyle = "#F6F4EF";
                ctx.fill();

                // Fine border: 1px rgba(0,0,0,0.04) -> #2E2E2B with 4% opacity
                ctx.shadowColor = "transparent"; // Disable shadow for stroke
                ctx.strokeStyle = "rgba(46, 46, 43, 0.04)";
                ctx.lineWidth = 1.0;
                ctx.stroke();
            }

            Component.onCompleted: requestPaint()
        }

        // Spacious contents aligned exactly inside the 24px margins (592x432 area)
        Column {
            anchors.fill: parent
            anchors.margins: 40 // Generous 40px inset for architectural calm
            spacing: 24

            // Dynamic Input Field - Secondary Warm Paper surface (#FBFAF7)
            TextField {
                id: searchField
                width: parent.width
                height: 48
                placeholderText: "Search apps, formulas, or system settings..."
                placeholderTextColor: "#5966645E" // Secondary 35% warm gray ink
                
                color: "#2E2E2B" // Primary ink charcoal
                font.family: "Outfit, Inter, sans-serif"
                font.pixelSize: 15
                
                background: Rectangle {
                    color: "#FBFAF7" // Nook secondary warm-paper
                    radius: 10 // Smooth corner rounding
                    border.color: searchField.activeFocus ? "rgba(46, 46, 43, 0.15)" : "rgba(46, 46, 43, 0.05)"
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
                height: parent.height - 88
                spacing: 6
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
                    color: mouseArea.containsMouse ? "#EFECE5" : "transparent" // Nook sidebar surface on hover
                    radius: 10 // Symmetrical rounding
                    
                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutQuint }
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 16

                        // App Icon placeholder - Warm background card
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 8
                            color: "#FBFAF7" // Secondary warm-paper
                            border.color: "rgba(46, 46, 43, 0.03)"
                            border.width: 1

                            Text {
                                text: "❖"
                                color: "#66645E"
                                font.pixelSize: 14
                                anchors.centerIn: parent
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: modelData.name
                                color: "#2E2E2B" // Primary grounding charcoal-ink
                                font.family: "Outfit, Inter, sans-serif"
                                font.weight: Text.Medium
                                font.pixelSize: 14
                            }
                            Text {
                                text: modelData.desc
                                color: "#66645E" // Secondary warm gray ink
                                font.family: "Outfit, Inter, sans-serif"
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
                            if (modelData.name === "Kitty Terminal") {
                                Quickshell.execDetached(["kitty"])
                            }
                            window.toggle()
                        }
                    }
                }
            }
        }
    }
}
