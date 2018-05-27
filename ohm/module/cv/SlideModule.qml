import ohm.module 1.0
import ohm.jack.out 1.0
import ohm.jack.in 1.0

Module {
    objectName: "SlideModule"

    label: "Slide"

    outJacks: [
        OutJack {
	    label: "output"
	    stream: 'sum(eval(subst(x,t,@input),x,t-@delay+1ms*n),n,1,11)/10'
	}
    ]

    inJacks: [
        InJack {label: 'input'},
        InJack {label: 'delay'},
    ]

    cvs: [
	AttenuverterCV {
	    label: 'input'
	    inVolts: inStream('input')
	},
	LogScaleCV {
	    label: 'input'
	    inVolts: inStream('delay')
	    from: '200ms'
	}
    ]
	
}

