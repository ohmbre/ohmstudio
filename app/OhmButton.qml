import QtQuick.Controls 2.4
import QtQuick 2.11

RoundButton {
    id: control
    radius: implicitHeight/2
    padding: 10
    property string imageUrl: null
    property double border: 4
    property Image image: Image {
        source: imageUrl
        mipmap: true
    }
    property OhmText label: OhmText {
        text: control.text
        color: Style.buttonTextColor
        font.bold: true
        font.pixelSize: 11
    }
    contentItem: imageUrl ? image : label
    background: Rectangle {
        radius: control.radius
        anchors.fill: control
        color: control.imageUrl ? "#00000000" : (control.down ? Style.buttonOverColor : Style.buttonColor)
        border.width: control.border
        border.color: Style.buttonBorderColor
    }
}
