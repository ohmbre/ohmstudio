import QtQuick 2.10
import QtQuick.Controls 2.3
import Qt.labs.folderlistmodel 2.1

import ohm 1.0
import ohm.module 1.0
import ohm.cable 1.0

Flickable {
    id: patchView
    property Patch patch

    anchors.fill: parent
    contentWidth: 1600; contentHeight: 1200
    contentX: contentWidth/2 - width/2
    contentY: contentHeight/2 - height/2
    flickableDirection: Flickable.HorizontalAndVerticalFlick
    scale: 1
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
            onPressAndHold: addModuleMenu.popup()
        }
    }


    StyledMenu {
        id: addModuleMenu
        title: "Add Module"
        Component.onCompleted: {

        }

    }

    StyledMenu {
        id: delModuleMenu
        title: "Delete Module?"; width: 85;
        Action { text: 'No!' }
        Action { text: 'Yes.'; onTriggered: patch.deleteModule(delModuleMenu.candidate); }
        property Module candidate
    }

    function confirmDeleteModule(module) {
        delModuleMenu.candidate = module;
        delModuleMenu.popup();
    }

    Timer {
        interval: 3000; running: true; repeat: true
        onTriggered: {
            if (patch.cueAutoSave)
		patch.autosave();
        }
    }

    CableDragView {id: childCableDragView; }
    property alias cableDragView: childCableDragView

}



