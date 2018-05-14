import ohm.module 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0
import ohm.cv 1.0

Module {
    objectName: "ADSRModule"

    label: "ADSR"

    outJacks: [
        OutJack {
	    label: "envelope"
	    stream: mul(8*v,oneshot(inStream('gate'),1,cv('attack'),cv('decay')))
	}
	
    ]

    inJacks: [
        InJack {label: "gate"},
	InJack {label: "attack"},
	InJack {label: "decay"}
    ]

    cvs: [
	LogScaleCV {
	    label: "attack"
	    voltage: inStream('attack')
	    from: 100*ms
	},
	LogScaleCV {
	    label: "decay"
	    voltage: inStream('decay')
	    from: 300*ms
	}
    ]
}
