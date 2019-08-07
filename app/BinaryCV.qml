import QtQuick 2.11

CV {
    id:bincv
    objectName: 'BinaryCV'

    controller: ToggleController {}
    reading: {
        if (controlVolts > 3)
            return "On"
        return "Off"
    }

    stream: 'max(%1, control(%2))'.arg(inVolts).arg(uuid(bincv))

}
