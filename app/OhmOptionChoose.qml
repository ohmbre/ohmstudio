import QtQuick 2.11
import QtQuick.Controls 2.4

Rectangle {
    id: optionDialog
    opacity: open ? 1 : 0
    visible: opacity > 0
    width: setup.width*0.65/scale;
    Behavior on opacity { NumberAnimation { duration: 700; easing.type: Easing.InOutQuad }}
    height: window.height*0.3/scale;
    color: Style.fileChooseBgColor
    x:15
    y: header.height+13
    transformOrigin: Item.TopLeft
    clip: true
    property real contentScale: 1
    property bool open

    ListView {
        id: outputChoose
        anchors.fill: parent
        headerPositioning: ListView.OverlayHeader
        keyNavigationEnabled: optionDialog.open
        highlightFollowsCurrentItem: true
        highlight: Rectangle { color: Style.fileChooseLitColor; radius: 7 }
        property bool open: optionDialog.open
        focus: optionDialog.open
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
            //height: 13
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.Wrap

            MouseArea {
                enabled: open
                anchors.fill: parent
                onClicked: {
                    HWIO.outName = modelData;
                    Fn.writeFile(Constants.optionsPath, JSON.stringify({audioOut: modelData}))
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
