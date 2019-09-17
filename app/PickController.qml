import QtQuick 2.13
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import QtQuick.Window 2.12

Item {
    id: pickController
    width: 110
    height: 16
    OhmText {
        color: 'white'
        text: displayLabel
        width: parent.width-control.width; height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 8
    }

    ComboBox {
        id: control
        currentIndex: choice
        width: 80; height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        font.pixelSize: 7
        font.family: asapMedium.name
        contentItem: Rectangle {
            z:0
            anchors.fill: parent;
            color: 'white'
            border.color: control.hovered ? 'black' : 'gray'
            border.width: 1

            OhmText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 3
                text: choices[control.currentIndex]
                color: 'black'
                font.pixelSize: 6
            }
        }
        popup.height: Math.min(popup.contentItem.implicitHeight, window.height/window.globalScale * 0.75)

        popup.scale: window.globalScale
        popup.transformOrigin: Item.Left
        delegate: ItemDelegate {
            width: 100
            height: 12
            text: modelData
            padding: 2
            rightPadding: 0
            bottomPadding: 0
            topPadding: 0
            leftPadding: 3
            font.family: asapMedium.name
            font.pixelSize: 6
            font.bold: control.currentIndex == index
            highlighted: control.highlightedIndex == index
            hoverEnabled: true
        }
        indicator: OhmText {
            z: 1
            font.pixelSize: 8
            font.bold: true
            text: "⬎"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 2
        }
        model: choices
        onActivated: choice = index
    }

}
