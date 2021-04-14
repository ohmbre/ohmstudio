import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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
    onFocusChanged: {
        if (!focus)
            chooser.expanded = false
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
            enabled: !chooser.expanded
            preventStealing: true
            anchors.fill: chooser
            hoverEnabled: enabled
            scrollGestureEnabled: true
            onEntered: chooser.border.color = 'black'
            onExited: chooser.border.color = 'gray'
            onClicked: {
                chooser.expanded = true
                choiceBox.focus = true;
            }
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
                id: choiceRepeater
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
                            choiceBox.focus = false
                        }
                    }
                }
            }
        }
    }
    property alias model: choiceRepeater.model
    property string choice
    property int choiceIdx: model.indexOf(choice)
    signal chosen(string newChoice)

}
