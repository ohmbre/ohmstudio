import ohm.module 1.0
import ohm.jack.out 1.0
import ohm.jack.in 1.0
import ohm.cv 1.0

Module {
    objectName: "RandSeqModule"
    label: "Random Sequencer"

    outJacks: [
        OutJack {
	    label: "v/oct"
	    stream: clockSeq(jack('clock').stream,1,sample(scaleToVoct('minorBlues'),8))
	},
	OutJack {
	    label: "trig"
	    stream: jack('clock').stream
	}
    ]

    inJacks: [
        InJack {label: "clock"}
    ]
}
