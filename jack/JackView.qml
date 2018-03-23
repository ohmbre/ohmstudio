import QtQuick 2.10
import QtQuick.Shapes 1.11
import "helpers.js" as F

Shape {
    id: jackView
    property Jack jack
    property double clearRadians
    property double sweepRadians
    property double centerRadians
    property double scaleX
    property double scaleY
    property color bgColor
    property color bgColorLit
    anchors.centerIn: parent
    z: -2

    property ShapePath path: ShapePath {
        strokeColor: "orange"
        strokeWidth: 2
        fillColor: bgColor
        startX: 0; startY: 0

        PathLine {
            id: linePath
            x: scaleX * Math.cos(centerRadians-sweepRadians/2)
            y: -scaleY * Math.sin(centerRadians-sweepRadians/2)
        }
        PathArc {
            id: arcPath
            radiusX: scaleX
            radiusY: scaleY
            x: scaleX * Math.cos(centerRadians+sweepRadians/2)
            y: -scaleY * Math.sin(centerRadians+sweepRadians/2)
            direction: PathArc.Counterclockwise
        }
        PathLine {x: 0; y:0}

    }

    StyledText{
        text: jack.label;
        color: "yellow";
        centered: false
        y: -height/2
        x: -height/2
        transform: [Rotation {angle: -centerRadians*180/Math.PI},
         Translate {
            x: scaleX*Math.cos(centerRadians)
            y: -scaleY*Math.sin(centerRadians)
        }]
    }
    Component.onCompleted: {
        jack.view = jackView;
        //F.dDump(linePath);
    }
}
