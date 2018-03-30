import ".."
import "../.."
import "../../.."
HwModule {
    objectName: "GateHwModule"
    label: "Gate Out"
    inJacks: [
        GateInJack {
            label: "trig"
        },
        OutJack {label: "wtf"},
        OutJack {label: "test"},
        OutJack {label: "hello"}
    ]
}
