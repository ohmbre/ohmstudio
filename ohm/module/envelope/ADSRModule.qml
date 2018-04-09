import ohm.module 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0

Module {
    objectName: "ADSRModule"

    label: "ADSR"

    outJacks: [
        OutJack {label: "envelope"}
    ]

    inJacks: [
        InJack {label: "gate"}
    ]
}
