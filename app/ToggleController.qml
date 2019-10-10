import QtQuick 2.12
import QtQuick.Controls 2.5

Switch {
    id: control
    text: displayLabel
    width: 35; height: 25
    property double value: volts
    onValueChanged: {
        if (volts >= 3 && !checked) toggle()
        else if (volts < 3 && checked) toggle()
    }
    onCheckedChanged: volts = checked ? 10 : 0
    indicator: Item {
        x: 0; y: 0; width: control.width; height: control.height
        Image {
            clip: true
            source: control.checked ? 'qrc:/app/ui/icons/down.svg' : 'qrc:/app/ui/icons/up.svg'
            x: control.width*.05; y: 0; width: control.width*.9; height: control.height*.6
        }
        OhmText {
            x: 0; y: control.height*.6; width: control.width; height: 6
            text: control.text
            color: 'black'
            font.pixelSize: 6
            horizontalAlignment: Text.AlignHCenter

        }
    }
    contentItem: Item {}
}

