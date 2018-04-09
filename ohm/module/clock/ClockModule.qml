import ohm.module 1.0
import ohm.jack.out.gate 1.0
import ohm.jack.in 1.0

Module {
    objectName: "ClockModule"

    label: "Clock"

    outJacks: [
        GateOutJack {label: "trig"}
    ]

    inJacks: [
        InJack {label: "tempo"}
    ]
}
