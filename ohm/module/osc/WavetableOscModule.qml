import ohm.module 1.0
import ohm.jack.out 1.0
import ohm.jack.in 1.0

Module {
    objectName: "WavetableOscModule"
    label: "Wavetable Osc"

    outJacks: [
        OutJack {label: "signal"}
    ]

    inJacks: [
        InJack {label: "v/oct"}
    ]
}
