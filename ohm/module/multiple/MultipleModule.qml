import ohm.module 1.0
import ohm.jack.out 1.0
import ohm.jack.in 1.0
import ohm.helpers 1.0

Module {
    objectName: "MultipleModule"
    label: "Multiple"

    outJacks: [
        OutJack {
	    label: "out1"
	    stream: inStream('in')
	},
	OutJack {
	    label: "out2"
	    stream: inStream('in')
	}
    ]

    inJacks: [
        InJack {
	    label: "in";
	}
    ]

}
