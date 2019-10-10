import ohm 1.0

Module {

    label: 'Sample Hold'
    InJack {label: 'signal'}
    InJack {label: 'trig'}
    OutJack {
        label: 'out'
        stateVars: ({sample: 0, gate: 0})
        expression: 'sample := (gate == 0) and (trig > 3) ? signal : sample;
                     gate := (trig > 3) ? 1 : 0;
                     sample'
    }

}
