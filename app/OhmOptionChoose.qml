import QtQuick 2.11
import QtQuick.Controls 2.4

Item {
    id: optionDialog
    opacity: open ? 1 : 0
    visible: opacity > 0
    width: setup.width*0.65/scale;
    Behavior on opacity { NumberAnimation { duration: 700; easing.type: Easing.InOutQuad }}
    x:15
    y: header.height+13
    property bool open: false
    transformOrigin: Item.TopLeft


    Rectangle {
        width: parent.width
        height: 95;
        x: 0
        y: 0
        color: Style.fileChooseBgColor
        clip: true

        ListView {
            id: outputChoose
            anchors.fill: parent
            headerPositioning: ListView.OverlayHeader
            highlightFollowsCurrentItem: true
            highlight: Rectangle { color: Style.fileChooseLitColor; radius: 7 }
            model: HWIO.outList()
            currentIndex: model.indexOf(HWIO.outName);
            delegate: OhmText {
                leftPadding: 5
                rightPadding: 5
                topPadding: 2
                bottomPadding: 2
                text: modelData
                color: Style.fileChooseTextColor
                width: parent.width
                font.pixelSize: 7
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.Wrap

                MouseArea {
                    enabled: optionDialog.open
                    anchors.fill: parent
                    onClicked: {
                        HWIO.outName = modelData;
                        writeFile(Constants.optionsPath, JSON.stringify({audioOut: modelData}))
                    }
                }
            }

            header: Rectangle {
                width: parent.width
                height:17
                OhmText {
                    text: "Audio Outputs"
                    color: Style.fileChooseTextColor
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    padding: 2
                    leftPadding: 4
                    horizontalAlignment: Text.AlignLeft
                }
                color: Style.buttonBorderColor
                clip: true
                z:5
            }
        }
    }


    Rectangle {
        width: parent.width
        height: 95;
        x: 0
        y: 110
        color: Style.fileChooseBgColor
        clip: true

        ListView {
            id: inputChoose
            anchors.fill: parent
            headerPositioning: ListView.OverlayHeader
            highlightFollowsCurrentItem: true
            highlight: Rectangle { color: Style.fileChooseLitColor; radius: 7 }
            model: HWIO.inList()
            currentIndex: model.indexOf(HWIO.inName);
            delegate: OhmText {
                leftPadding: 5
                rightPadding: 5
                topPadding: 2
                bottomPadding: 2
                text: modelData
                color: Style.fileChooseTextColor
                width: parent.width
                font.pixelSize: 7
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.Wrap

                MouseArea {
                    enabled: optionDialog.open
                    anchors.fill: parent
                    onClicked: {
                        HWIO.inName = modelData;
                    }
                }
            }

            header: Rectangle {
                width: parent.width
                height: 17
                OhmText {
                    text: "Audio Inputs"
                    color: Style.fileChooseTextColor
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    padding: 2
                    leftPadding: 4
                    horizontalAlignment: Text.AlignLeft
                }
                color: Style.buttonBorderColor
                clip: true
                z:5
            }
        }
    }

}
