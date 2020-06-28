import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: choiceBox
    width: 150
    height: 12
    OhmText {
        id: label
        color: 'black'
        width: choiceBox.width*0.8; height: choiceBox.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 8
    }
    property alias label: label.text
    Rectangle {
        id: chooser
        width: parent.width*.8
        height: choiceBox.height * (expanded ? choiceBox.model.length : 1)
        clip: true
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        color: 'white'
        border.color: 'gray'
        border.width: 1
        property bool expanded: false
        MouseArea {
            enabled: !parent.expanded
            anchors.fill: parent
            hoverEnabled: enabled
            onEntered: parent.border.color = 'black'
            onExited: parent.border.color = 'gray'
            onClicked: parent.expanded = true
        }
        OhmText {
            font.pixelSize: 8
            font.bold: true
            text: "⬎"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 2
        }
        Column {
            width: parent.width * .9;
            x: parent.width *.05;
            y: -choiceBox.choiceIdx * (chooser.expanded ? 0 : choiceBox.height);
            Repeater {
                id: choices
                OhmText {
                    property bool selected: modelData == choiceBox.choice
                    property bool hovered: false
                    width: choiceBox.width*.7
                    horizontalAlignment: Text.AlignLeft
                    height: choiceBox.height
                    text: modelData
                    color: 'black'
                    font.pixelSize: 4
                    font.bold: selected || hovered
                    MouseArea {
                        enabled: chooser.expanded
                        anchors.fill: parent
                        hoverEnabled: enabled
                        onEntered: parent.hovered = true
                        onExited: parent.hovered = false
                        onClicked: {
                            choiceBox.chosen(parent.text)
                            chooser.expanded = false
                            parent.hovered = false
                        }
                    }
                }
            }
        }
    }
    property alias model: choices.model
    property string choice
    property int choiceIdx: model.indexOf(choice)
    signal chosen(string newChoice)

}
