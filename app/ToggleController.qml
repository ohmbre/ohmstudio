import QtQuick 2.12
import QtQuick.Controls 2.5

Switch {
    id: control
    text: displayLabel
    width: 30; height: 25
    property double value: volts
    onValueChanged: {
        if (volts >= 3 && !checked) toggle()
        else if (volts < 3 && checked) toggle()
    }
    onCheckedChanged: volts = checked ? 10 : 0
    indicator: Item {
        x: 0; y: 0; width: 30; height: 25
        Image {
            source: control.checked ? 'qrc:/app/ui/icons/down.svg' : 'qrc:/app/ui/icons/up.svg'
            x: 0; y: 0; width: 30; height: 15
        }
        OhmText {
            x: 0; y: 15; width: 30; height: 6
            text: control.text
            color: 'black'
            font.pixelSize: 6
            horizontalAlignment: Text.AlignHCenter

        }
    }
    contentItem: Item {}
}

