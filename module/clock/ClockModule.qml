import ".."
import "../.."
Module {
    objectName: "ClockModule"

    label: "Clock"
    /*cvs: [
        CV {
            label: "Rate (per m)"
            valAtZero: 120
            radix: 1.5
        },
        CV {
            label: "Hold Time (ms)"
            valAtZero: 10
            radix: 1.5
        }
    ]*/
    outJacks: [
        GateOutJack {label: "trig"},
        OutJack {label: "wtf"},
        OutJack {label: "test"}
    ]
    inJacks: [
        InJack {
            label: "tempo"
        }
    ]
}
