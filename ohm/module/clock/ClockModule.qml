import ohm.module 1.0
import ohm.jack.out.gate 1.0
import ohm.jack.in 1.0
import ohm.cv 1.0

Module {
    objectName: 'ClockModule'

    label: 'Clock'

    outJacks: [
        GateOutJack {
	    label: 'trig'
	    stream: 'test(mod(t,1/@tempo)<30ms,10v,0v)'
	}
    ]

    inJacks: [
        InJack {label: 'tempo'}
    ]

    cvs: [
	LogScaleCV {
	    label: 'tempo'
	    inVolts: inStream('tempo')
	    from: '120/m'
	}
    ]
}
