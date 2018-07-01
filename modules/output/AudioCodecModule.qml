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

    property Timer streamSender: Timer {
        interval: 100; running: false; repeat: false
        onTriggered: {
            engine.codec.msg({cmd:'set', key:'streams', val:[outL,outR]})
        }
    }

    onOutLChanged: streamSender.restart()
    onOutRChanged: streamSender.restart()

    Component.onCompleted: engine.codec.msg({cmd:'set', key:'audioEnabled', val:true})
    Component.onDestruction: engine.codec.msg({cmd:'set', key:'audioEnabled', val:false})
}


