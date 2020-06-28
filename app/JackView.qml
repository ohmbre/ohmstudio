import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: jView
    property Jack jack
    property bool isOut
    property int direction: isOut? -1 : 1
    property double extension: 0
    property var shapeData
    property color bgColor
    property color bgColorLit
    property point posRef
    anchors.fill: parent

    NumberAnimation { id: extendAnim; target: jView; property: 'extension'; from: 0; to: 1 }
    NumberAnimation { id: collapseAnim; target: jView; property: 'extension'; from: 1; to: 0 }
    function extend() {
        if (extension < 0.5) extendAnim.start()
    }
    function collapse() {
        if (extension > 0.5) collapseAnim.start()
    }

    property double mR: mView.height/2
    property double s: shapeData.start
    property double c: shapeData.center
    property double e: shapeData.end
    property double sx: toX(s); property double sy: toY(s)
    property double szx: toXz(s); property double szy: toYz(s)
    property double cx: toX(c); property double cy: toY(c)
    property double czx: toXz(c); property double czy: toYz(c)
    property double ex: toX(e); property double ey: toY(e)
    property double ezx: toXz(e); property double ezy: toYz(e)
    property double r0: mView.cstart
    property double r0x: toX(r0); property double r0y: toY(r0)
    property double r0zx: toXz(r0); property double r0zy: toYz(r0)
    property double r1: mView.tstart
    property double r1x: toX(r1); property double r1y: toY(r1)
    property double r1zx: toXz(r1); property double r1zy: toYz(r1)
    property double zz: extension * 10

    function toX(pos) {
    return posRef.x + direction*((pos <= r0) ? (mView.width/2 - mR - pos)
                     : ((pos < r1) ? (-mR * Math.sin((pos-r0)/mR)) : (pos-r1)))
    }
    function toY(pos) {
    return posRef.y + ((pos <= r0) ? mR : ((pos < r1) ? (mR*Math.cos((pos-r0)/mR)) : -mR))
    }
    function toXz(pos) {
    return posRef.x + direction*((pos <= r0) ? (mView.width/2 - mR - pos)
                     : ((pos < r1) ? (-(mR+zz) * Math.sin((pos-r0)/mR)) : (pos-r1)))
    }
    function toYz(pos) {
    return posRef.y + ((pos <= r0) ? (mR+zz) :
               ((pos < r1) ? ((mR+zz)*Math.cos((pos-r0)/mR)) : -(mR+zz)))
    }

    z: -1
    Shape {
        id: jackShape
        anchors.fill: parent
        containsMode: Shape.FillContains
        smooth: true
        layer.samples: 4
        antialiasing: true
        z: -2
        ShapePath {
            id: shapePath
            fillColor: bgColor
            strokeWidth: 1
            strokeColor: Qt.darker(bgColor)
            joinStyle: ShapePath.RoundJoin
            startX: sx; startY: sy
            PathLine { // if botline
                x: (s < r0) ? ((e < r0) ? ex : r0x) : sx
                y: (s < r0) ? ((e < r0) ? ey : r0y) : sy
            }
            PathArc {
                radiusX: mView.height/2
                radiusY: mView.height/2
                direction: isOut ? PathArc.Counterclockwise : PathArc.Clockwise
                x: (e > r1) ? ((s < r1) ? r1x : sx) : ex
                y: (e > r1) ? ((s < r1) ? r1y : sy) : ey
            }
            PathLine { x: ex; y: ey }
            PathLine { x: ezx; y: ezy }
            PathLine {
                x: (e > r1) ? ((s < r1) ? r1zx : szx) : ezx
                y: (e > r1) ? ((s < r1) ? r1zy : szy) : ezy
            }
            PathArc {
                radiusX: mR+zz
                radiusY: mR+zz
                direction: isOut ? PathArc.Clockwise : PathArc.Counterclockwise
                x: (s > r0) ? szx : ((e < r0) ? ezx : r0zx)
                y: (s > r0) ? szy : ((e < r0) ? ezy : r0zy)
            }
            PathLine { x: szx; y: szy }
            PathLine {
                x:sx; y:sy
            }
        }

        MouseArea {
            id: jackPad
            property Item parentModuleView: mView
            x: -10
            y: -10
            width: parent.width + 20
            height: parent.height + 20
            propagateComposedEvents: false
            preventStealing: true
            hoverEnabled: true
            drag.smoothed: true
            drag.threshold: 0
            onPressed: function(e) {
                if (jackShape.contains(Qt.point(jackPad.mouseX-10,
                                                jackPad.mouseY-10))) {
                    e.accepted = true
                    pView.cableDragView.cableStarted(jView);
                }
                else e.accepted = false
            }
        }
    }
    property alias shape: jackShape
    property alias path: shapePath
    property alias pad: jackPad
    property double extRad: parent.height/2+27
    property double extRadHalf: parent.height/2+5



    property double anchor1X: cx + mView.x
    property double anchor1Y: cy + mView.y
    property double anchor2X: posRef.x - direction * extRadHalf * Math.cos(shapeData.theta) + mView.x
    property double anchor2Y: posRef.y - extRadHalf * Math.sin(shapeData.theta) + mView.y
    property double anchor3X: posRef.x - direction * 1.5*extRad * Math.cos(shapeData.theta) + mView.x
    property double anchor3Y: posRef.y - 1.5*extRad * Math.sin(shapeData.theta) + mView.y

    Item {
        id: middle

        x: cx - (isOut ? 0 : 10)
        y: cy - 4
        width: 10
        height: 8
        OhmText {
            id: jackLabel
            x: isOut ? 10 : 0
            y:0; width: 0; height: 8
            text: jack.label
            property color blend: Qt.darker(bgColor)
            color: Qt.rgba(blend.r, blend.g, blend.b, 0.98 * (jack.hasCable ? 1 : extension))
            horizontalAlignment: isOut ? Text.AlignLeft : Text.AlignRight
            font.pixelSize: 6
            font.weight: Font.Bold
            rightPadding: (isOut ? 0 : 1.5)
            leftPadding: (isOut ? 1.5 : 0)
        }
        Text {
            x: 0; y: 1.5
            width: 10; height: 5;
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: isOut ? Text.AlignLeft : Text.AlignRight
            opacity: jack.hasCable ? 1 : extension
            text: "⤳"
            font.pixelSize: 10
            color: Qt.darker(bgColor)
        }

        rotation: direction*shapeData.theta*180/Math.PI
        transformOrigin: isOut ? Item.Left : Item.Right
    }

    property bool dropTargeted: false
    onDropTargetedChanged: {
        if (dropTargeted) shapePath.fillColor = bgColorLit;
        else shapePath.fillColor = bgColor;
    }

    Component.onCompleted: {
        jack.view = jView;
    }
}


