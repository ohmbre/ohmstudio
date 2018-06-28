import ohm.module 1.0
import ohm.jack.out.gate 1.0
import ohm.jack.in 1.0
import ohm.cv 1.0

Module {
    objectName: 'ClockDividerModule'

    label: 'Clock Divider'

    outJacks: [
        GateOutJack {
	    label: 'clkout'
	    stream: 'clkdiv($clkin,round(@div,0),round(@shift,0))'
	}
    ]

    inJacks: [
        InJack {label: 'clkin'},
	InJack {label: 'div'},
	InJack {label: 'shift'}
    ]

    cvs: [
	LogScaleCV {
	    logBase: 1.5
	    label: 'div'
	    inVolts: inStream('div')
	    from: 2
	},
	LinearCV {
	    label: 'shift'
	    inVolts: inStream('shift')
	    from: 0
	}
    ]
}
