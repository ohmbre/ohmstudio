import ohm.module 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0
import ohm.dsp 1.0

Module {
    objectName: "VCAModule"
    label: "VCA"

    outJacks: [
        OutJack {
	    label: "out"
	    stream: with(DSP) mul(1./(8*v),mul(jack('gain').stream,jack('in').stream))
	}
    ]

    inJacks: [
        InJack {label: "in"},
        InJack {
	    label: "gain"
	    defaultStream: with(DSP) repeat(8*v)
	}
    ]
}
