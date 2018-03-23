import QtQuick 2.10
import QtQuick.Shapes 1.11
import "helpers.js" as F

Shape {
    width: patchView.width;
    height: patchView.height;
    property Connection connection
    property Item jov: connection.fromOutJack.view
    property Item jiv: connection.toInJack.view
    ShapePath {
    id: connectionView
    strokeWidth: 2.5
    strokeColor: Style.edgeColor
    fillColor: "transparent"
    joinStyle: ShapePath.RoundJoin
    strokeStyle: ShapePath.SolidLine
    startX: F.centerX(jov.parent)
    startY: F.centerY(jov.parent)

    PathCubic {
        property double c: 3
        x: F.centerX(jiv.parent)
        y: F.centerY(jiv.parent)
        control1X:
             c * jov.scaleX*Math.cos(jov.centerRadians) + F.centerX(jov.parent)
        control1Y:
            -c * jov.scaleY*Math.sin(jov.centerRadians) + F.centerY(jov.parent)
        control2X:
             c * jiv.scaleX*Math.cos(jiv.centerRadians) + F.centerX(jiv.parent)
        control2Y:
            -c * jiv.scaleY*Math.sin(jiv.centerRadians) + F.centerY(jiv.parent)
    }

    Component.onCompleted: {
        connection.view = connectionView;
    }
}
}

