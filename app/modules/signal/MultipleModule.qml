import ohm 1.0

Module {
    label: "Multiple"

    InJack { label: "input" }
    OutJack {
        label: "out1"
        expression: "input"
    }
    OutJack {
        label: "out2"
        expression: "input"
    }
    OutJack {
        label: "out3"
        expression: "input"
    }
    OutJack {
        label: "out4"
        expression: "input"
    }
}
