import ohm.module 1.0
import ohm.jack.out 1.0
import ohm.jack.in 1.0
import ohm.helpers 1.0

Module {
    objectName: 'MixModule'
    label: 'Mixer'

    outJacks: [
        OutJack {
	    label: 'out'
	    stream: '($in1 + $in2)/2'
	}
    ]

    inJacks: [
        InJack {
	    label: 'in1'
	},
	InJack {
	    label: 'in2'
	}
    ]

}
