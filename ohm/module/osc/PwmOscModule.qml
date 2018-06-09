import ohm.module 1.0
import ohm.jack.out 1.0
import ohm.jack.in 1.0
import ohm.helpers 1.0
import ohm.cv 1.0

Module {
    objectName: 'PwmOscModule'
    label: 'PWM Osc'

    outJacks: [
        OutJack {
	    label: 'signal'
	    stream: '@gain * pwm(@freq,@duty/20)'
	}
    ]

    inJacks: [
        InJack { label: 'v/oct' },
	InJack { label: 'duty' },
	InJack { label: 'gain' }
    ]

    cvs: [
	LogScaleCV {
	    label: 'freq'
	    inVolts: inStream('v/oct')
	    from: 'notehz(C,4)'
	},
	LinearCV {
	    label: 'duty'
	    inVolts: inStream('duty')
	    from: '10'
	},
	LogScaleCV {
	    label: 'gain'
	    inVolts: inStream('gain')
	    from: 2
	    logBase: 1.38
	}
    ]
    

}
