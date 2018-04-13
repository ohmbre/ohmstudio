import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQml 2.2

Menu {
    id: menuHolder
    width: 70
    height: 70
    property int itemHeight: 16
    property Component contents
    background: Item {}
    Rectangle {
        id: header
        width:parent.width
        height: 13
        color: "#00000000"
        Label {
            id: label
            height: 20
            color: "white"
            text: menuHolder.title;
            font.bold: true
            font.pixelSize: 9
            verticalAlignment: Text.AlignBottom
            horizontalAlignment: Text.AlignRight
            anchors.right: header.right; anchors.top: header.top
            leftPadding: 4; rightPadding: 4;
            bottomPadding: 6;
            background: Rectangle {
                color: "#000000";
                border.color: "white";  border.width: 1
                anchors.fill: parent
                radius: 6;
            }
        }
    }

    Rectangle {
        id: body
        color: "white";
        y: header.height
        height: menuHolder.height - y;
        width: menuHolder.width;
        clip: true
        Loader {
            sourceComponent: menuHolder.contents
        }
    }
    property alias body: body

}
