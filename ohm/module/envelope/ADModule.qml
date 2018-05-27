import ohm.module 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0
import ohm.cv 1.0

Module {
    objectName: 'ADModule'

    label: 'A/D Envelope'

    outJacks: [
        OutJack {
	    label: 'envelope'
	    stream: '10v * do(start=whenlast(t,uptrigger($gate)), test(t - start < @attack,'+
		'eval(t^@attshape,t,(t - start)/@attack),'+
		'test(t-start-@attack < @decay, eval((1-t)^@decshape,t,(t - start - @attack)/@decay)))'
	}
	
    ]

    inJacks: [
        InJack {label: 'gate'},
	InJack {label: 'attack'},
	InJack {label: 'decay'}
    ]

    cvs: [
	LogScaleCV {
	    label: 'attack'
	    inVolts: inStream('attack')
	    from: '100ms'
	},
	LogScaleCV {
	    label: 'decay'
	    inVolts: inStream('decay')
	    from: '300ms'
	}
	// -2->1/3 -1->1/2   0->1, 1->2, 2->3 
    ]
}
