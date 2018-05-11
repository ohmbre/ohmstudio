import ohm.module 1.0
import ohm.jack.out 1.0
import ohm.jack.in 1.0
import ohm.helpers 1.0
import ohm.dsp 1.0

Module {
    objectName: "MultipleModule"
    label: "Multiple"

    outJacks: [
        OutJack {
	    label: "out1"
	    stream: jack('in').stream
	},
	OutJack {
	    label: "out2"
	    stream: jack('in').stream
	}
    ]

    inJacks: [
        InJack {
	    label: "in";
	}
    ]

}
