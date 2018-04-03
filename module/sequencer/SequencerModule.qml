import ".."
import "../.."
Module {
    objectName: "SequencerModule"

    label: "Sequencer"

    outJacks: [
        GateOutJack {label: "v/oct"},
        GateOutJack {label: "trig"}
    ]

    inJacks: [
        InJack {label: "clock"}
    ]
}
