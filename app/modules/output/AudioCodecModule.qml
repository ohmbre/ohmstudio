import QtQuick 2.11
import ohm 1.0

Module {
    id: codec
    objectName: 'AudioCodecModule'
    label: 'Audio Codec'

    outJacks: [
        OutJack {
            label: 'inL'
            stream: 'capture(0)'
        },
        OutJack {
            label: 'inR'
            stream: 'capture(1)'
        }
    ]

    inJacks: [
        InJack { label: 'outL' },
        InJack { label: 'outR' }
    ]

    property var outL: inStream('outL')
    property var outR: inStream('outR')
    property Timer setStreamDelayed: Timer {
        interval: 200; running: false; repeat: false
        onTriggered: {
            checked(()=>{ engine.setStream('outL',outL) }, outL)
            checked(()=>{ engine.setStream('outR',outR) }, outR)
        }
    }
    onOutLChanged: setStreamDelayed.restart()
    onOutRChanged: setStreamDelayed.restart()
    Component.onDestruction: {
        checked(()=>{ engine.setStream('outL',0) }, outL)
        checked(()=>{ engine.setStream('outR',0) }, outR)
    }
}


