import ohm.module 1.0
import ohm.jack.in 1.0

Module {
    objectName: "OutAudioHwModule"

    label: "Audio Out"

    outJacks: []

    inJacks: [
        InJack {label: "signal"}
    ]
}
