import QtQuick
import QtQuick.Controls

Switch {
    id: control
    text: displayLabel
    width: 48; height: 18
    property double value: volts
    onValueChanged: {
        if (volts >= 3 && !checked) toggle()
        else if (volts < 3 && checked) toggle()
    }
    onCheckedChanged: volts = checked ? 10 : 0
    indicator: Item {
        x: 0; y: 0; width: control.width; height: control.height
        OhmText {
            width: control.width*.3; height: control.height
            text: control.text
            color: 'black'
            font.pixelSize: 6
            horizontalAlignment: Text.AlignRight
            rightPadding: 4
        }
        Image {
            clip: true
            source: control.checked ? 'qrc:/app/ui/icons/down.svg' : 'qrc:/app/ui/icons/up.svg'
            x:control.width*.3; width: control.width*.7; height: control.height
        }

    }
    contentItem: Item {}
}

