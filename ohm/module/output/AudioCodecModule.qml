import QtQuick 2.11

import ohm.ui 1.0
import ohm.module 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0
import ohm.cv 1.0
import Brig.SinkThread 1.0

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
    onOutLChanged: thread.sendMessage(
	JSON.stringify({cmd:'set',key:'streams', val:[outL,outR]}))
    onOutRChanged: thread.sendMessage(
	JSON.stringify({cmd:'set',key:'streams',subkey:1, val:[outL,outR]}))

    property SinkThread thread: SinkThread {
	Component.onDestruction: kill()
    }

    Component.onCompleted: thread.sendMessage(
	JSON.stringify({cmd:'set',key:'audioEnabled',val:true}))

}


