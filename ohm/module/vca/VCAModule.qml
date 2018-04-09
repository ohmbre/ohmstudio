import ohm.module 1.0
import ohm.jack.in 1.0
import ohm.jack.out.gate 1.0

Module {
    objectName: "VCAModule"
    label: "VCA"

    outJacks: [
        GateOutJack {label: "signal"}
    ]

    inJacks: [
        InJack {label: "signal"},
        InJack {label: "gain"}
    ]
}
