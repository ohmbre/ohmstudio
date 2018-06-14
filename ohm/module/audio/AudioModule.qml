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

    property AudioThread audioThread: AudioThread {
	eqnL: inStream('outL')
	eqnR: inStream('outR')
	Component.onDestruction: kill()
    }
}
