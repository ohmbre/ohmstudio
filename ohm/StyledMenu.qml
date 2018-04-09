import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQml 2.2

Menu {

    id: menu
    width: 70
    topPadding: header.height
    background: Rectangle {
        width:parent.width
        height: header.height
        color: "#00000000"
        Rectangle {
            id: header
            width: childrenRect.width
            height: 11
            x: parent.width - childrenRect.width
            clip: true
            color: "#00000000"
            Label {
                text: title;
                font.bold: true
                font.pixelSize: 9
                height: parent.height
                color: "white";
                leftPadding: 4; rightPadding: 4; topPadding: 1;
                background: Rectangle {
                    color: "#000000"; border.color: "white";  border.width: 1
                    radius: 4; height:parent.height+radius;
                }
            }
        }

        Rectangle {color: "white"; height: 16 * menu.count; width: parent.width; y: 11; }
    }

    delegate: MenuItem {
        id: menuItem
        height: 16
        contentItem: StyledText {
            text: menuItem.text
            color: "black"
        }
    }

}
