import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQml 2.11

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
        height: 12.2
        color: "#00000000"
    smooth: true
    z: 2
    x: 0
        Label {
            id: label
        smooth: true
            height: 15
            color: "white"
            text: menuHolder.title;
            font.bold: true
            font.pixelSize: 9
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            anchors.right: header.right; anchors.top: header.top
            leftPadding: 4; rightPadding: 4;
            bottomPadding: 0;
            background: Rectangle {
                color: "#000000";
                border.color: "white";  border.width: 1
                anchors.fill: parent
                radius: 3;
            }
        }
    }

    Rectangle {
        id: body
        color: "#CAFFFFFF";
        height: menuHolder.height-header.height;
        width: menuHolder.width;
    radius: 3
    smooth: true
    property alias contentLoader: contentLoader
        Loader {
        id: contentLoader
        focus: true
            sourceComponent: menuHolder.contents
        }
    }

    property alias body: body

}
