import QtQuick 2.13
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12

Item {
    id: choiceBox
    width: 150
    height: 16
    property var choiceLabels
    signal chosen(int index)
    OhmText {
        id: label
        color: 'black'
        text: choiceBox.label
        width: choiceBox.width*0.8; height: choiceBox.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 8
    }
    property alias label: label

    ComboBox {
        id: control
        width: choiceBox.width*0.8; height: 16
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        font.pixelSize: 7
        font.family: asapMedium.name
        contentItem: Rectangle {
            z:0
            anchors.fill: parent
            color: 'white'
            border.color: control.hovered ? 'black' : 'gray'
            border.width: 1
            OhmText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 3
                text: (control.currentIndex >= 0 && control.currentIndex < choiceBox.choiceLabels.length) ? choiceBox.choiceLabels[control.currentIndex] : ''
                color: 'black'
                font.pixelSize: 6
            }
        }
        popup.height: Math.min(popup.contentItem.implicitHeight, window.height/window.globalScale * 0.75)
        popup.width: control.width*1.2

        popup.scale: window.globalScale
        popup.transformOrigin: Item.Left
        delegate: ItemDelegate {
            width: control.width*1.2
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
        model: choiceBox.choiceLabels
        onActivated: choiceBox.chosen(index)
    }
    property alias control: control

}
