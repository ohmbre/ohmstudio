import ohm.module 1.0
import ohm.jack.out.gate 1.0
import ohm.jack.in 1.0
import ohm.cv 1.0

Module {
    objectName: "ClockModule"

    label: "Clock"

    outJacks: [
        GateOutJack {
	    label: "trig"
	    stream: cycle(1, 30*ms, add(cv('tempo'),-30*ms))
	}
    ]

    inJacks: [
        InJack {label: "tempo"}
    ]

    cvs: [
	LogScaleCV {
	    label: "tempo"
	    voltage: inStream('tempo')
	    from: 200*ms
	}
    ]
}
