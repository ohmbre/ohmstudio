import QtQuick 2.11

CV {
    id:bincv
    objectName: 'BinaryCV'

    controller: ToggleController {}
    voltStream: (vc,vi) => `max(${vc}, ${vi})`
}
