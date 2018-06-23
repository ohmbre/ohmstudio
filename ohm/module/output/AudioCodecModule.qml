import QtQuick 2.11

import ohm.ui 1.0
import ohm.module 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0
import ohm.cv 1.0

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
    onOutLChanged: engine.codec.msg({cmd:'set',key:'streams',val:[outL,outR]})
    onOutRChanged: engine.codec.msg({cmd:'set',key:'streams',val:[outL,outR]})


    Component.onCompleted: engine.codec.msg({cmd:'set',key:'audioEnabled',val:true})

}


