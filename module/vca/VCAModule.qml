import ".."
import "../.."
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
