import ohm.module 1.0
import ohm.jack.out 1.0
import ohm.jack.in 1.0
import ohm.helpers 1.0
import ohm.cv 1.0

Module {
    objectName: "SawOscModule"
    label: "Saw Osc"

    outJacks: [
        OutJack {
	    label: "signal"
	    stream: mul(10*v, saw(cv('freq')))
	}
    ]

    inJacks: [
        InJack { label: "v/oct" }
    ]

    cvs: [
	LogScaleCV {
	    label: "freq"
	    voltage: inStream('v/oct')
	    from: noteToHz('D',1)
	}
    ]
    

}
