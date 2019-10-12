import ohm 1.0

Module {

    label: 'Sample Hold'
    InJack {label: 'signal'}
    InJack {label: 'trig'}
    Variable { label: 'sample' }
    Variable { label: 'gate' }
    OutJack {
        label: 'out'
        expression: 'sample := (gate == 0) and (trig > 3) ? signal : sample;
                     gate := (trig > 3) ? 1 : 0;
                     sample'
    }

}
