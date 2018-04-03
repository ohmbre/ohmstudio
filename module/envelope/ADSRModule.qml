import ".."
import "../.."
Module {
    objectName: "ADSRModule"

    label: "ADSR"

    outJacks: [
        GateOutJack {label: "envelope"}
    ]

    inJacks: [
        InJack {label: "gate"}
    ]
}
