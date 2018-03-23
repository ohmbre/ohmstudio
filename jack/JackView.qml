import QtQuick 2.10
import QtQuick.Shapes 1.11
import ".."
import "../Helpers.js" as F

Shape {
    id: jackView
    property Jack jack
    property int index
    readonly property double minPadRadians: 0.1
    readonly property double maxSweepRadians: 1.0
    property double clearRadians: 2*Math.PI / moduleView.module.inJacks.length
    property double sweepRadians: Math.min(clearRadians - minPadRadians, maxSweepRadians)
    property double centerRadians: index * clearRadians + Math.PI/2
    property double extend
    property double scaleX: extend * moduleView.width/2
    property double scaleY: extend * moduleView.height/2
    property color bgColor
    property color bgColorLit
    anchors.centerIn: parent
    z: -2

    property ShapePath path: ShapePath {
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
        color: Style.jackLabelColor;

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
        //F.dDump(jackView);
    }
}
