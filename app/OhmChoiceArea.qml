import QtQuick 2.15
import QtQml.Models 2.15
import QtQuick.Layouts 1.15


Rectangle {
    id: choiceArea

    color: 'white'
    OhmText {
        id: header
        width: parent.width
        height: 8
        font.pixelSize: 6
        color: 'black'
        text: heading
        wrapMode: Text.NoWrap
    }

    signal chosen()

    property string heading
    property var model
    property var choices
    property double itemWidth
    property double itemHeight

    width: itemWidth*layout.columns
    height: itemHeight*layout.rows

    property alias layout: layout
    GridLayout {
        id: layout
        height: parent.height - header.height
        width: parent.width
        y: header.height

        flow: GridLayout.LeftToRight
        rowSpacing: 0
        columnSpacing: 0
        Repeater {
            id: repeater
            model: choiceArea.model
            delegate: Loader {
                active: true
                Layout.alignment: Layout.Center
                sourceComponent: Rectangle {
                    width: choiceArea.itemWidth
                    height: choiceArea.itemHeight
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            const chosenPos = choiceArea.choices.indexOf(modelData)
                            if (chosenPos >= 0) choiceArea.choices.splice(chosenPos,1)
                            else choiceArea.choices.push(modelData)
                            choiceArea.choices = choiceArea.choices
                            chosen();
                        }
                    }
                    Rectangle {
                        width: parent.width + border.width*2
                        height: parent.height + border.width*2
                        x: -border.width
                        y: -border.width
                        border.width: 0.5
                        border.color: 'black'
                        color: choiceArea.choices.indexOf(modelData) >= 0 ? 'blue' : 'white'
                        OhmText {
                            anchors.fill: parent
                            font.pixelSize: 4
                            text: modelData
                            color: choiceArea.choices.indexOf(modelData) >= 0 ? 'white' : 'black'
                        }
                    }
                }
            }
        }
    }

}

