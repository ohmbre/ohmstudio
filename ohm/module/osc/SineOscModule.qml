import ohm.module 1.0
import ohm.jack.out 1.0
import ohm.jack.in 1.0
import ohm.dsp 1.0
import ohm.cv 1.0

Module {
    objectName: "SineOscModule"
    label: "Sine Osc"

    outJacks: [
        OutJack {
	    label: "signal"
	    stream: with(DSP) mul(10*v, sinusoid(cv('freq')))
	}
    ]

    inJacks: [
        InJack {
	    label: "v/oct";
	}
    ]

    cvs: [
	LogScaleCV {
	    label: "freq"
	    voltage: jack('v/oct').stream
	    from: with(DSP) noteToHz('C',4)
	}
    ]
    

}
