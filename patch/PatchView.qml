import QtQuick 2.10
import QtQuick.Shapes 1.11

Flickable {
    id: patchView
    property Patch patch
    anchors.fill: patchView.parent
    contentWidth: width*2; contentHeight: height*2
    contentX: width/2; contentY: height/2
    flickableDirection: Flickable.HorizontalAndVerticalFlick

    //maximumFlickVelocity: 10

    Repeater {
        model: patch.modules
        ModuleView {
           module: modelData
           coords: Qt.point(index * 30, -index * 30)
        }
    }


    Repeater {
        model: patch.connections
        ConnectionView {
           connection: modelData
        }
    }


    PinchArea {
        anchors.fill: parent
        pinch.target: patchView.contentItem
        pinch.minimumScale: 0.1
        pinch.maximumScale: 10
        pinch.dragAxis: Pinch.XAndYAxis
    }
     /*   MouseArea {
            anchors.fill: parent
            anchors.centerIn: parent
            scrollGestureEnabled: false
            propagateComposedEvents: true
            //preventStealing: true
            onWheel: {
                console.log("wheel");
                patchView.contentItem.scale += patchView.contentItem.scale * wheel.angleDelta.y / 120 / 10;

            }
        }

    }*/

}



