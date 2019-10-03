import ohm 1.0

Module {
    label: 'Flip Flop'
    InJack {label: 'trig'}
    OutJack {
        label: 'out'
        expression: "
           state := ((gate == 0) and (trig > 3)) ? (10 - state) : state;
           gate := (trig > 3) ? 1 : 0;
           state"
    }
}
