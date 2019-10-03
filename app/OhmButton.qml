import QtQuick.Controls 2.5
import QtQuick 2.12

RoundButton {
    id: control
    radius: implicitHeight/2
    padding: 5
    property double border: 4
    font.pixelSize: 11
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
        font.weight: Font.DemiBold
        color: control.down ? 'white' : 'black'
        padding: control.padding
        verticalAlignment: control.verticalAlignment
    }
}
