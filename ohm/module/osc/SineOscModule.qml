import ohm.module 1.0
import ohm.jack.out 1.0
import ohm.jack.in 1.0
import ohm.cv 1.0

Module {
    objectName: 'SineOscModule'
    label: 'Sine Osc'

    outJacks: [
        OutJack {
	    label: 'signal'
	    stream: '@gain*sinusoid(@freq)'
	}
    ]

    inJacks: [
        InJack { label: 'v/oct' },
	InJack { label: 'gain' }
    ]

    cvs: [
	LogScaleCV {
	    label: 'freq'
	    inVolts: inStream('v/oct')
	    from: 'notehz(C,4)'
	},
	LinearCV {
	    label: 'gain'
	    inVolts: inStream('gain')
	    from: '5v'
	}
    ]
    

}
