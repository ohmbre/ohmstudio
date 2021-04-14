Module {
    label: "Multiple"

    InJack { label: "input" }
    
    OutJack {
        label: "out1"
        calc: "double calc() { return input; }"
    }
    OutJack {
        label: "out2"
        calc: "double calc() { return input; }"
    }
    OutJack {
        label: "out3"
        calc: "double calc() { return input; }"
    }
    OutJack {
        label: "out4"
        calc: "double calc() { return input; }"
    }
}
