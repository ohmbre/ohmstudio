import ".."
import "../.."
Module {
    objectName: "WavetableOscModule"

    label: "Wavetable Osc"

    outJacks: [
        GateOutJack {label: "signal"}
    ]

    inJacks: [
        InJack {label: "v/oct"}
    ]
}
