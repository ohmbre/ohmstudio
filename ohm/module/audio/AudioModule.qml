import QtQuick 2.10

import ohm.module 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0
import Brig.AudioThread 1.0

Module {
    objectName: 'AudioModule'
    id: audioOut
    label: 'Audio Out/In'

    outJacks: []

    inJacks: [
        InJack { label: 'L' },
	InJack { label: 'R' }
    ]

    property AudioThread audioThread: AudioThread {
	eqnL: inStream('L')
	eqnR: inStream('R')
	Component.onDestruction: kill()
    }
}
