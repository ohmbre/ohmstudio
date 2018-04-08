import QtQuick 2.10
import ".."
import "../Helpers.js" as F

Flickable {
    id: patchView
    property Patch patch

    anchors.fill: parent
    contentWidth: 1600; contentHeight: 1200
    contentX: contentWidth/2 - width/2
    contentY: contentHeight/2 - height/2
    flickableDirection: Flickable.HorizontalAndVerticalFlick
    scale: 2
    //maximumFlickVelocity: 10

    Repeater {
        model: patch.modules
        ModuleView {
            module: modelData
        }
    }


    Repeater {
        model: patch.cables
        CableView {
           cable: modelData
        }
    }

    PinchArea {
        anchors.fill: parent
        pinch.target: patchView.contentItem
        pinch.minimumScale: 0.1
        pinch.maximumScale: 5
        pinch.dragAxis: Pinch.XAndYAxis

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
    }

    Timer {
        interval: 3000; running: true; repeat: true
        onTriggered: {
            if (patch.cueAutoSave) {
                patch.cueAutoSave = false
                F.writeFile(Constants.autoSavePath, patch.toQML())
            }
        }
    }

    CableDragView {id: childCableDragView; }
    property alias cableDragView: childCableDragView

}



