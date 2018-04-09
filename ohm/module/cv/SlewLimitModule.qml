import ohm.module 1.0
import ohm.jack.out 1.0
import ohm.jack.in 1.0

Module {
    objectName: "SlewLimitModule"

    label: "SlewLimit"

    outJacks: [
        OutJack {label: "slewed"}
    ]

    inJacks: [
        InJack {label: "limit"},
        InJack {label: "signal"}

    ]
}

