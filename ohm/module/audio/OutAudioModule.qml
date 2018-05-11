import QtQuick 2.10

import ohm.module 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0
import ohm.dsp 1.0

Module {
    objectName: "OutAudioModule"
    id: audioOut
    label: "Audio Out"

    outJacks: []

    inJacks: [
        InJack {
	    label: "signal"
	}
    ]  

    property AudioThread audioThread: AudioThread {
	property var streamStr: jack('signal').stream
    }

    Component.onCompleted: audioThread.start()

    
}
