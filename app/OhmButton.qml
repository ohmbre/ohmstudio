import QtQuick.Controls 2.15
import QtQuick 2.15

RoundButton {
    id: control
    radius: implicitHeight/2
    padding: 3
    property double border: 2
    font.pixelSize: 8
    width: 60

    property int verticalAlignment: Text.AlignVCenter
    background: Rectangle {
        radius: control.radius
        anchors.fill: control
        color: control.imageUrl ? "#00000000" : (control.down ? 'black' : 'white')
        border.width: control.border
        border.color: 'black'
    }
    contentItem: OhmText {
        text: control.text
        font.family: asapSemiBold.name
        font.pixelSize: control.font.pixelSize
        font.weight: Font.Bold
        color: control.down ? 'white' : 'black'
        padding: control.padding
        verticalAlignment: control.verticalAlignment
    }
}
