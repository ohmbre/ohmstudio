import ohm 1.0

Module {

    label: 'Gate'
    InJack {label: 'trig'}
    InJack {label: 'inHold'}
    CV {
        label: 'ctrlHold'
        translate: v=>500 * 1.3**v
        unit: 'ms'
    }
    Variable { label: 'gate' }
    Variable { label: 't'; value: 99999999 }
    OutJack {
        label: 'gate'
        expression:
            't := (gate == 0) and (trig > 3) ? 0 : t+1;
             gate := (trig > 3) ? 1 : 0;
             (t < 500ms*1.3^(inHold+ctrlHold)) ? 10 : 0'
    }

}
