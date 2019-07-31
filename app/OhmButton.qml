import QtQuick.Controls 2.5
import QtQuick 2.11

RoundButton {
    id: control
    radius: implicitHeight/2
    padding: 10
    property double border: 4
    background: Rectangle {
        radius: control.radius
        anchors.fill: control
        color: control.imageUrl ? "#00000000" : (control.down ? Style.buttonOverColor : Style.buttonColor)
        border.width: control.border
        border.color: Style.buttonBorderColor
    }
    contentItem: OhmText {
        text: control.text
        font.family: "Asap Semibold"
        font.pixelSize: 11
        color: Style.buttonTextColor;
        verticalAlignment: Text.AlignVCenter;

    }
}
