import QtQuick 2.10

import ".."

Flickable {
    id: patchView
    property Patch patch

    anchors.fill: parent
    contentWidth: 1600; contentHeight: 1200
    contentX: contentWidth/2 - width/2
    contentY: contentHeight/2 - height/2
    flickableDirection: Flickable.HorizontalAndVerticalFlick
    antialiasing: true


    //maximumFlickVelocity: 10

    Repeater {
        model: patch.modules
        ModuleView {
            module: modelData
            coords: Qt.point(index * 40, -index * 40)
        }
    }


    Repeater {
        model: patch.edges
        EdgeView {
           edge: modelData
        }
    }

    PinchArea {
        anchors.fill: parent
        pinch.target: patchView.contentItem
        pinch.minimumScale: 0.1
        pinch.maximumScale: 10
        pinch.dragAxis: Pinch.XAndYAxis
    }

    MouseArea {
        anchors.fill: parent
        anchors.centerIn: parent
        scrollGestureEnabled: false
        propagateComposedEvents: true
        //preventStealing: true
        onWheel: {
            patchView.contentItem.scale += patchView.contentItem.scale * wheel.angleDelta.y / 120 / 10;

        }
    }

    EdgeDragView {id: childEdgeDragView}
    property alias edgeDragView: childEdgeDragView

}



