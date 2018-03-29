import QtQuick 2.10
import QtQuick.Shapes 1.11
import ".."
import "../Helpers.js" as F

Shape {
    property Edge edge
    property OutJackView ojv: edge.fromOutJack.view
    property ModuleView ojm: ojv.parent
    property InJackView ijv: edge.toInJack.view
    property ModuleView ijm: ijv.parent

    width: patchView.width;
    height: patchView.height;
    antialiasing: true
    layer.samples: 4

    ShapePath {
        id: edgeView
        strokeWidth: 2.5
        strokeColor: Style.edgeColor
        fillColor: "transparent"
        joinStyle: ShapePath.RoundJoin
        strokeStyle: ShapePath.SolidLine
        startX: F.centerX(ojm)
        startY: F.centerY(ojm)

        PathCubic {
            id: pathCubic
            property double c: Style.edgeControlStiffness
            x: F.centerX(ijm)
            y: F.centerY(ijm)
            control1X:
            c * ojv.r*Math.cos(ojv.theta) + F.centerX(ojm)
            control1Y:
            -c * ojv.r*Math.sin(ojv.theta) + F.centerY(ojm)
            control2X:
            c * ijv.r*Math.cos(ijv.theta) + F.centerX(ijm)
            control2Y:
            -c * ijv.r*Math.sin(ijv.theta) + F.centerY(ijm)

        }
    }

    Component.onCompleted: {
        edge.view = edgeView;
    }
}

