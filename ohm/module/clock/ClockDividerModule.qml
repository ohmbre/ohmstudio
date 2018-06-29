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
	    stream: 'clkdiv($clkin,@div,@shift)'
	}
    ]

    inJacks: [
	InJack {label: 'div'},
        InJack {label: 'clkin'},
	InJack {label: 'shift'}
    ]

    cvs: [
	LinearCV {
	    label: 'div'
	    inVolts: inStream('div')
	    from: 10
	    onControlVoltsChanged: controlVolts = Math.round(controlVolts)
	},
	LinearCV {
	    label: 'shift'
	    inVolts: inStream('shift')
	    from: 0
	    onControlVoltsChanged: controlVolts = Math.round(controlVolts)
	}
    ]
}
