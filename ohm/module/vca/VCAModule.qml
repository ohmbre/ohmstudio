import ohm.module 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0
import ohm.cv 1.0

Module {
    objectName: 'VCAModule'
    label: 'VCA'

    outJacks: [
        OutJack {
	    label: 'out'
	    stream: '@gain/(5v) * $in'
	}
    ]

    inJacks: [
        InJack { label: 'in' },
        InJack {
	    label: 'gain'
	    defaultStream: '5v'
	}
    ]

    cvs: [
	LinearCV {
	    label: 'gain'
	    inVolts: inStream('gain')
	    from: '0v'
	}
    ]
}
