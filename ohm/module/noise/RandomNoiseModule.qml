import ohm.module 1.0
import ohm.jack.out 1.0
import ohm.jack.in 1.0
import ohm.cv 1.0

Module {
    objectName: 'RandomNoiseModule'
    label: 'Random Noise'

    outJacks: [
        OutJack {
	    label: 'signal'
	    stream: '@gain*noise(@seed)'
	}
    ]

    inJacks: [
	InJack { label: 'gain' },
	InJack { label: 'seed' }
    ]

    cvs: [
	LogScaleCV {
	    label: 'gain'
	    inVolts: inStream('gain')
	    from: 2
	    logBase: 1.38
	},
	LinearCV {
	    label: 'seed'
	    inVolts: inStream('seed')
	    from: 666
	    onControlVoltsChanged: controlVolts = Math.round(controlVolts)
	}
    ]
    

}
