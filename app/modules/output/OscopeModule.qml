import QtQuick 2.11
import ohm 1.0

Module {

    id: oscope
    objectName: 'OscopeModule'
    label: 'Scope'

    inJacks: [
        InJack { label: 'signal' },
        InJack { label: 'trig' }
    ]

    cvs: [
        LinearCV {
            label: 'vtrig'
            inVolts: 0
        },
        ExponentialCV {
            label: 'window'
            logBase: 1.3
            inVolts: 0
            from: '150ms'
        }
    ]

    display: OhmScope {

        trig: cvs[0].controlVolts * 12.7
        win: cvs[1].reading
        signalStream: oscope.inStream('signal')
        trigStream: oscope.inStream('trig')
        vtrigStream: oscope.cvStream('vtrig')
        winStream: oscope.cvStream('window')

    }
}





