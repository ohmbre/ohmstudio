import QtQuick.Controls 2.5
import QtQuick 2.11

RoundButton {
    id: control
    radius: implicitHeight/2
    padding: 10
    property double border: 4
    //color: Style.buttonTextColor
    font.bold: true
    font.pixelSize: 11
    background: Rectangle {
        radius: control.radius
        anchors.fill: control
        color: control.imageUrl ? "#00000000" : (control.down ? Style.buttonOverColor : Style.buttonColor)
        border.width: control.border
        border.color: Style.buttonBorderColor
    }
}
