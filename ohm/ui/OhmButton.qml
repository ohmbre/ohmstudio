import QtQuick.Controls 2.3
import QtQuick 2.9

RoundButton {
    id: control
    text: "button"
    radius: 8
    implicitHeight: 20
    implicitWidth: 20
    padding: 0
    property url imageUrl
    property Image image: Image {
        height: control.implicitHeight
        width: control.implicitWidth
        autoTransform: false
        source: imageUrl
        fillMode: Image.Stretch
    }
    property OhmText label: OhmText {
        height: 14
        width: 20
        text: "hello?" //control.text
        color: "black"
    }
    contentItem: image ? image : label
    background: Rectangle {
        radius: control.radius
        anchors.fill: control
        color: control.imageUrl ? "#00000000" : (control.down ? Style.buttonOverColor : Style.buttonColor)
    }
}
