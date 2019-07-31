import QtQuick 2.0
import QtQuick.Controls 2.4

Item {
    property Component indicator
    property Component editor
    width: parent.width
    Loader {
        id: indicatorLoader
        sourceComponent: indicator
    }
    property alias indicatorItem: indicatorLoader.item
    property var clickHandler: function(mouse) {
        if (editor) editCtrl.open()
    }
    MouseArea {
        id: inidicatorClick
        anchors.fill: parent
        onClicked: clickHandler(mouse)
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
