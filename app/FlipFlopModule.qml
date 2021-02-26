Module {
    label: 'Flip Flop'
    InJack {label: 'trig'}
    Variable { label: 'state' }
    Variable { label: 'gate' }
    OutJack {
        label: 'out'
        expression:
           "state := ((gate == 0) and (trig > 3)) ? (10 - state) : state;
            gate := (trig > 3) ? 1 : 0;
            state"
    }
}
