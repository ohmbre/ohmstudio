import QtQuick 2.10
import QtQuick.Shapes 1.11
import ".."
import "../Helpers.js" as F

Shape {
    id: jackView
    property Jack jack
    property int position
    property int siblings
    property int direction
    property double extend

    property double extendRatio: .7
    readonly property double minPadRadians: 0.1
    readonly property double maxSweepRadians: 0.8
    property double clearRadians: 2*Math.PI / siblings
    property double sweepRadians: Math.min(clearRadians - minPadRadians, maxSweepRadians)
    property double centerRadians: direction * (position * clearRadians + Math.PI/2)
    property double scaleY: (extendRatio*extend+1) * moduleView.height/2
    property double scaleX: scaleY + (moduleView.width - moduleView.height)/2;
    property color bgColor
    property color bgColorLit
    x: F.centerRectX(jackView, moduleView)
    y: F.centerRectY(jackView, moduleView)
    z: -2
    ShapePath {
        id: shapePath
        fillColor: bgColor
        strokeColor: "#00000000"

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
    Item {
        height: childrenRect.height
        y: -height/2.0 -(scaleY+2)*Math.sin(centerRadians)
        x: (scaleX+2)*Math.cos(centerRadians)
        rotation: -centerRadians*180/Math.PI
        transformOrigin: Item.Left

        Text{
            text: jack.label;
            property color bg: Style.jackLabelColor
            color: Qt.rgba(bg.r, bg.g, bg.b, bg.a * extend);
            font.family: asapFont.name
            font.pixelSize: 8
            rotation: (parent.x >= 0 ? 0 : 180)
        }
    }

    MouseArea {
        height: 30
        width: 30
        hoverEnabled: true
        onEntered: shapePath.fillColor = bgColorLit
        onExited: shapePath.fillColor = bgColor
    }

    Component.onCompleted: {
        jack.view = jackView;
        F.dDump(jackView);
    }
}


