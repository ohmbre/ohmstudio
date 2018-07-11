import QtQuick 2.11
import QtQuick.Shapes 1.11

Shape {
    id: rect
    containsMode: Shape.FillContains
    layer.enabled: {
    return Qt.platform.os == 'android' || Qt.platform.os == 'ios' ||
        Qt.platform.os == 'linux' || Qt.platform.os == 'osx'
    }
    layer.samples: 16
    layer.smooth: true
    layer.mipmap: true
    width: wb*10
    height: hb*10
    property double wb
    property double hb
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

    property alias pad: pad
    MouseArea {
        id: pad
        enabled: true
        anchors.fill: parent
        drag.target: parent.dragTarget
        drag.smoothed: true
        propagateComposedEvents: true
        preventStealing: true
        scrollGestureEnabled: false
        hoverEnabled: true
        containmentMask: rect
        pressAndHoldInterval: 800
        onPressAndHold: rect.pressAndHold(mouse)
        onClicked: rect.clicked(mouse)
    }
}


