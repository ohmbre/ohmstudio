import QtQuick 2.11
import QtQuick.Shapes 1.11

Shape {
    id: rect
    containsMode: Shape.FillContains
    layer.enabled: true
    layer.samples: 16
    layer.smooth: true
    layer.mipmap: true
    width: size.width*10
    height: size.height*10
    property size size
    property bool eventsEnabled: true
    property double radius
    property double border
    property double b: (border/2)*10
    property double r: (radius-b)
    property double w: (width-b)
    property double h: (height-b)
    property color borderColor
    property color color
    scale: 0.1
    transformOrigin: Item.TopLeft
    
    ShapePath {
	fillColor: rect.color
	strokeColor: rect.borderColor
	strokeWidth: rect.border*10
	startX: b; startY: r
	PathArc {
	    radiusX: r; radiusY: r
	    x: r; y: b
	}
	PathLine { x: w - r; y: b }
	PathArc {
	    radiusX: r; radiusY: r
	    x: w; y: r;
	}
	PathLine { x: w; y: h - r }
	PathArc {
	    radiusX: r; radiusY: r
	    x: w-r; y: h
	}
	PathLine { x: r; y: h }
	PathArc {
	    radiusX: r; radiusY: r
	    x: b; y: h - r
	}
	PathLine { x: b; y: r }
    }

    property Item dragTarget
    signal clicked
    signal pressAndHold
    
    
    MouseArea {
	id: pad
        anchors.fill: parent
	drag.target: parent.dragTarget
        drag.smoothed: true
	drag.threshold: 5
        propagateComposedEvents: true
        preventStealing: true
	hoverEnabled: true

	function inside(event) {
	    return rect.contains(Qt.point(event.x, event.y)) && rect.eventsEnabled
	}
	
        pressAndHoldInterval: 800	
        onPressAndHold: function(e) {
	    if (inside(e)) rect.pressAndHold(e)
	    else e.accepted = false
        }
	
	onClicked: function(e) {
            if (inside(e)) rect.clicked(e)
	    else e.accepted = false
        }

    }
}
	    
	
