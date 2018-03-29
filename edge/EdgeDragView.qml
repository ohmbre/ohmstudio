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
    property point dragCoords

    width: patchView.width
    height: patchView.height
    antialiasing: true
    layer.samples: 4

    Rectangle{
        id: dragDot;
        width: 5; height: 5; radius: 2.5;
        x: dragCoords.x
        y: dragCoords.y
        z: 3;
    }
    property alias target: dragDot

    signal dragStarted(point mousePos, JackView jv)
    onDragStarted: {
        var relPos = edgeDragView.mapFromGlobal(mousePos.x, mousePos.y);
        dragDot.x = relPos.x
        dragDot.y = relPos.y
        startJackView = jv
        console.warn(dragDot.x + ',' + dragDot.y)
    }

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
            when: startJackView == null
            PropertyChanges { target: dragShape; startX: 0; startY: 0; strokeColor: "transparent" }
            PropertyChanges { target: dragCurve; x: 0; y: 0; control1X: 0; control1Y: 0; control2X: 0; control2Y: 0 }
        },
        State {
            extend: "dragging"
            when: endJackView == null
            PropertyChanges {
                target: dragCurve;
                x: F.centerX(dragDot); y: F.centerY(dragDot)
                control2X: F.centerX(dragDot); control2Y: F.centerY(dragDot)
            }
        },
        State {
            name: "dragging"
            when: startJackView != null
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

