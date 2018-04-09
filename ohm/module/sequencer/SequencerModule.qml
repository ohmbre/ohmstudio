import ohm.module 1.0
import ohm.jack.out 1.0
import ohm.jack.out.gate 1.0
import ohm.jack.in 1.0

Module {
    objectName: "SequencerModule"

    label: "Sequencer"

    outJacks: [
        OutJack {label: "v/oct"},
        GateOutJack {label: "trig"}
    ]

    inJacks: [
        InJack {label: "clock"}
    ]
}
