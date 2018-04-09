import ohm.module.hw 1.0
import ohm.jack.out 1.0
import ohm.jack.in.gate 1.0

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
