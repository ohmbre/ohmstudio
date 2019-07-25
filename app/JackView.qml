import QtQuick 2.11
import QtQuick.Shapes 1.11

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
    property bool hasCable: pView.patch.lookupCableFor(jack).cable && true

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
    property double zz: extension * Style.jackExtension

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
        z: -2
        ShapePath {
            id: shapePath
            fillColor: bgColor
            strokeWidth: 0
            strokeColor: Qt.rgba(0,0,0,0)
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
            x: -Style.jackExtension
            y: -Style.jackExtension
            width: parent.width + Style.jackExtension*2
            height: parent.height + Style.jackExtension*2
            propagateComposedEvents: false
            preventStealing: true
            hoverEnabled: true
            drag.smoothed: true
            drag.threshold: 0
            onPressed: function(e) {
                if (jackShape.contains(Qt.point(jackPad.mouseX-Style.jackExtension,
                                                jackPad.mouseY-Style.jackExtension))) {
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
    property double extRad: parent.height/2+Style.jackExtension*2.7
    property double extRadHalf: parent.height/2+Style.jackExtension/2

    property double anchor1X: cx + mView.x
    property double anchor1Y: cy + mView.y
    property double anchor2X: posRef.x - direction * extRadHalf * Math.cos(shapeData.theta) + mView.x
    property double anchor2Y: posRef.y - extRadHalf * Math.sin(shapeData.theta) + mView.y
    property double anchor3X: posRef.x - direction * extRad * Math.cos(shapeData.theta) + mView.x
    property double anchor3Y: posRef.y - extRad * Math.sin(shapeData.theta) + mView.y

    Item {
        id: middle

        x: cx - (isOut ? 0 : Style.jackExtension)
        y: cy - 4
        width: Style.jackExtension
        height: 8
        OhmText {
            id: jackLabel
            x: isOut ? Style.jackExtension : 0
            y:0; width: 0; height: 8
            text: jack.label
            property color blend: Style.jackLabelColor
            color: Qt.rgba(blend.r, blend.g, blend.b, 0.98 * (jView.hasCable ? 1 : extension))
            horizontalAlignment: isOut ? Text.AlignLeft : Text.AlignRight
            font.pixelSize: 8
            font.weight: Font.Medium
            rightPadding: (isOut ? 0 : 1.5)
            leftPadding: (isOut ? 1.5 : 0)
        }

        Image {
            source: "qrc:/app/ui/icons/squiggle.svg"
            x: 0; y: 1.5
            width: Style.jackExtension
            height: 5
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: isOut ? Text.AlignLeft : Text.AlignRight
            rotation: 0
            transformOrigin: Item.Center
            opacity: hasCable ? 1 : extension
            mipmap: true
            smooth: true
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


