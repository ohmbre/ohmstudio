import ".."
import "../.."
import "../../.."
HwModule {
    objectName: "GateHwModule"
    label: "Gate Out"
    outJacks: [
        OutJack {label: "wtf"},
        OutJack {label: "test"},
        OutJack {label: "hello"},
        OutJack {label: "boo"}
    ]
    inJacks: [
        GateInJack {
            label: "trig"
        }
    ]
}
