import QtQuick 2.10
import QtQuick.Shapes 1.11
import ".."
import "../Helpers.js" as F

Shape {
    id: edgeDragView
    property JackView startJackView: null
    property JackView endJackView: null
    property ModuleView startModuleView: startJackView ? startJackView.parent : null
    property ModuleView endModuleView: endJackView ? endJackView.parent : null

    width: patchView.width
    height: patchView.height
    antialiasing: true
    layer.samples: 4

    Rectangle{
        id: dest
        width: 5; height: 5; radius: 2.5
        z: 3
    }
    property alias destination: dest

    ShapePath {
        id: dragShape
        strokeWidth: 2.5
        fillColor: "transparent"
        joinStyle: ShapePath.RoundJoin
        strokeStyle: ShapePath.SolidLine

        PathCubic {
            id: dragCurve
        }
    }
    states: [
        State {
            name: "normal"
            //when: startJackView == null
            PropertyChanges { target: dragShape; startX: 0; startY: 0; strokeColor: "transparent" }
            PropertyChanges { target: dragCurve; x: 0; y: 0; control1X: 0; control1Y: 0; control2X: 0; control2Y: 0 }
        },
        State {
            name: "dragging_no_hover"
            extend: "dragging"
            //when: endJackView == null && startJackView != null
            PropertyChanges {
                target: dragCurve;
                x: F.centerX(destination); y: F.centerY(destination)
                control2X: F.centerX(destination); control2Y: F.centerY(destination)
            }
        },
        State {
            name: "dragging"
            //when: startJackView != null
            changes: [
                PropertyChanges {
                    target: dragShape;
                    strokeColor: Style.edgeColor
                    startX: F.centerX(startModuleView);
                    startY: F.centerY(startModuleView)
                },
                PropertyChanges {
                    target: dragCurve;
                    control1X: Style.edgeControlStiffness * startJackView.r * Math.cos(startJackView.theta) + dragShape.startX
                    control1Y: Style.edgeControlStiffness * startJackView.r * -Math.sin(startJackView.theta) + dragShape.startY
                }
            ]
        }
    ]/*,
        State {
            name: "overjack"
            extend: "dragging"
            when: endJackView != null
            PropertyChanges {
                target: dragCurve;
                x: F.centerX(endModuleView); y: F.centerY(endModuleView)
                control2X: Style.edgeControlStiffness * endJackView.r * Math.cos(endJackView.theta) + x
                control2Y: Style.edgeControlStiffness * endJackView.r * -Math.sin(endJackView.theta) + y
            }
        }
    ]*/


}

