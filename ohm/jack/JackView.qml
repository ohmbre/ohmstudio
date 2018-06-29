import QtQuick 2.11
import QtQuick.Shapes 1.11

import ohm 1.0
import ohm.helpers 1.0
import ohm.ui 1.0
import ohm.module 1.0

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
            startX: posRef.x + direction * shapeData.start.x; startY: posRef.y + shapeData.start.y
	    pathElements: {
		var elements = []
		var cw = 'PathArc.Clockwise; '
		var ccw = 'PathArc.Counterclockwise; '
		if (isOut) {
		    var tmp = cw
		    cw = ccw
		    ccw = tmp
		}
		for (var p = 0; p < shapeData.path.length; p++) {
		    var path = shapeData.path[p]
		    var qml = 'import QtQuick 2.11; '
		    if (path.a) {
			qml += 'PathArc{ radiusX: %1; radiusY: %1; '.arg(path.a)
			qml += 'direction: ' + (path.d? ccw : cw)
		    } else qml += 'PathLine{ '
		    qml += 'x: %1; y:%2 }'.arg(posRef.x + direction * path.p.x).arg(posRef.y + path.p.y)
		    elements.push(Qt.createQmlObject(qml,jackShape,"dynShapePath"))
		}
		
		return elements
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
    property double centerX: posRef.x + direction*shapeData.center.x
    property double centerY: posRef.y + shapeData.center.y 
    
    property double anchor1X: centerX + mView.x
    property double anchor1Y: centerY + mView.y
    property double anchor2X: posRef.x - direction * extRadHalf * Math.cos(shapeData.theta) + mView.x
    property double anchor2Y: posRef.y - extRadHalf * Math.sin(shapeData.theta) + mView.y
    property double anchor3X: posRef.x - direction * extRad * Math.cos(shapeData.theta) + mView.x
    property double anchor3Y: posRef.y - extRad * Math.sin(shapeData.theta) + mView.y
    
    Item {
	id: middle
									       
	x: centerX - (isOut ? 0 : Style.jackExtension)
	y: centerY - 4
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
            source: "../ui/icons/squiggle.svg"
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


