import QtQuick 2.10

import ohm.module 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0
import Brig.AudioThread 1.0

Module {
    objectName: 'AudioModule'
    label: 'Audio Out/In'

    outJacks: [
	OutJack {
	    label: 'InL'
	    stream: 'capture(0)'
	},
	OutJack {
	    label: 'InR'
	    stream: 'capture(1)'
	}
    ]

    inJacks: [
        InJack { label: 'OutL' },
	InJack { label: 'OutR' }
    ]

    property AudioThread audioThread: AudioThread {
	eqnL: inStream('OutL')
	eqnR: inStream('OutR')
	Component.onDestruction: kill()
    }
}
