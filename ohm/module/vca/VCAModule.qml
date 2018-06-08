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

	    stream: '(@gain) * ($in + @inshift)'
	}
    ]

    inJacks: [
        InJack {
	    label: 'in'
	    defaultStream: '5'
	},
        InJack {
	    label: 'gain'
	}
    ]

    cvs: [
	LogScaleCV {
	    label: 'gain'
	    inVolts: inStream('gain')
	    from: 1
	    logBase: 1.6
	},
	LinearCV {
	    label: 'inshift'
	    from: 0
	}
	
    ]
}
