import QtQuick 2.0
import QtQuick.Controls 2.4

Item {
    id: controlView
    property Component indicator
    property Component editor
    width: parent.width
    Loader {
        sourceComponent: indicator
    }
    MouseArea {
        id: inidicatorClick
        anchors.fill: parent
        onClicked: editCtrl.open()
    }
    Popup {
        id: editCtrl
        modal: true
        focus: true
        padding: 0
        parent: Overlay.overlay
        scale: overlay.scale
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2.2)
        width: 215
        height: 107
        background: Rectangle {
            anchors.fill: parent
            color: 'transparent'
            radius: 10
        }
        Loader {
            sourceComponent: editor
            width: editCtrl.width
            height: editCtrl.height
        }
    }
}
