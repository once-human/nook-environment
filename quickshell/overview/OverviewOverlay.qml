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

    // Centered Visual Workspace Overview Grid Overlay - desaturating warm wash
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "#0a3c3224" // Sepia desaturating dim
        opacity: active ? 0.35 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 250; easing.type: Easing.OutQuint }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: window.toggle()
        }
    }

    // Grid Container
    Item {
        id: container
        anchors.fill: parent
        
        opacity: active ? 1.0 : 0.0
        scale: active ? 1.0 : 1.015 // Symmetrical subtle Nook scaling

        Behavior on opacity {
            NumberAnimation { duration: 220; easing.type: Easing.OutQuint }
        }
        Behavior on scale {
            NumberAnimation { duration: 250; easing.type: Easing.OutQuint }
        }

        Column {
            anchors.centerIn: parent
            spacing: 32
            width: parent.width * 0.85

            // Heading Title - Spacious Nook ink
            Text {
                text: "Desktop Workspaces Overview"
                color: "#2E2E2B" // Primary grounding charcoal-ink
                font.family: "Outfit, Inter, sans-serif"
                font.pixelSize: 22
                font.weight: Font.DemiBold
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // 10-Workspace Grid Layout
            Grid {
                columns: 5
                spacing: 16
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: 10

                    delegate: Item {
                        width: 240
                        height: 135

                        // --- MATHEMATICALLY EXACT SQUIRCLE CELL CANVAS ---
                        // Plots each workspace card (radius = 12px, n = 3.5) with soft ambient shadows
                        Canvas {
                            id: cellBg
                            anchors.fill: parent
                            renderTarget: Canvas.FramebufferObject
                            
                            property bool hovered: gridMouseArea.containsMouse
                            onHoveredChanged: requestPaint()

                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();

                                var w = width;
                                var h = height;
                                
                                // Continuous squircle corner radius (12px equivalent R)
                                var r = 12.0;
                                var n = 3.5;  // Exponent
                                
                                // Corner centers
                                var cx_tr = w - r;
                                var cy_tr = r;
                                var cx_tl = r;
                                var cy_tl = r;
                                var cx_bl = r;
                                var cy_bl = h - r;
                                var cx_br = w - r;
                                var cy_br = h - r;

                                var steps = 12;
                                var i;
                                var theta;

                                // Restrained atmospheric shadow system
                                if (hovered) {
                                    ctx.shadowColor = "rgba(46, 46, 43, 0.08)";
                                    ctx.shadowBlur = 12;
                                    ctx.shadowOffsetX = 0;
                                    ctx.shadowOffsetY = 4;
                                } else {
                                    ctx.shadowColor = "rgba(46, 46, 43, 0.03)";
                                    ctx.shadowBlur = 6;
                                    ctx.shadowOffsetX = 0;
                                    ctx.shadowOffsetY = 2;
                                }

                                ctx.beginPath();
                                ctx.moveTo(cx_tl, 0);
                                ctx.lineTo(cx_tr, 0);

                                // Quadrant 1: TR
                                for (i = 0; i <= steps; i++) {
                                    theta = (Math.PI / 2) * (1.0 - i / steps);
                                    ctx.lineTo(cx_tr + r * Math.pow(Math.cos(theta), 2/n), cy_tr - r * Math.pow(Math.sin(theta), 2/n));
                                }
                                ctx.lineTo(w, cy_br);

                                // Quadrant 2: BR
                                for (i = 0; i <= steps; i++) {
                                    theta = - (Math.PI / 2) * (i / steps);
                                    ctx.lineTo(cx_br + r * Math.pow(Math.cos(theta), 2/n), cy_br + r * Math.pow(Math.abs(Math.sin(theta)), 2/n));
                                }
                                ctx.lineTo(cx_bl, h);

                                // Quadrant 3: BL
                                for (i = 0; i <= steps; i++) {
                                    theta = - (Math.PI / 2) - (Math.PI / 2) * (i / steps);
                                    ctx.lineTo(cx_bl - r * Math.pow(Math.abs(Math.cos(theta)), 2/n), cy_bl + r * Math.pow(Math.abs(Math.sin(theta)), 2/n));
                                }
                                ctx.lineTo(0, cy_tl);

                                // Quadrant 4: TL
                                for (i = 0; i <= steps; i++) {
                                    theta = Math.PI - (Math.PI / 2) * (i / steps);
                                    ctx.lineTo(cx_tl - r * Math.pow(Math.abs(Math.cos(theta)), 2/n), cy_tl - r * Math.pow(Math.sin(theta), 2/n));
                                }
                                ctx.closePath();

                                // Fill with primary Nook paper white (#F6F4EF) or secondary soft paper white (#FBFAF7)
                                ctx.fillStyle = hovered ? "#FBFAF7" : "#F6F4EF";
                                ctx.fill();

                                // Fine border stroke
                                ctx.shadowColor = "transparent"; // Disable shadow for stroke
                                ctx.strokeStyle = hovered ? "rgba(46, 46, 43, 0.1)" : "rgba(46, 46, 43, 0.04)";
                                ctx.lineWidth = 1.0;
                                ctx.stroke();
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 12
                            
                            // Workspace Index number - grounding ink
                            Text {
                                text: (index + 1).toString()
                                color: "#2E2E2B" // Primary grounding ink charcoal
                                font.family: "Outfit, Inter, sans-serif"
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            // Minimal tactile representation of windows inside workspaces
                            Row {
                                spacing: 6
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                Rectangle {
                                    width: 32
                                    height: 20
                                    color: "#EFECE5" // Sidebar neutral surface
                                    radius: 4
                                    border.color: "rgba(46, 46, 43, 0.03)"
                                    border.width: 1
                                }
                                Rectangle {
                                    width: 48
                                    height: 20
                                    color: "#EAE7E1" // Matte background neutral
                                    radius: 4
                                    border.color: "rgba(46, 46, 43, 0.03)"
                                    border.width: 1
                                }
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
