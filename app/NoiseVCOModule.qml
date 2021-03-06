import ohm 1.0

Module {

    label: 'Noise VCO'
    InJack { label: 'inGain' }
    CV {
        label: 'ctrlGain'
        volts: 3
    }
    Variable { label: 'state'; value: 666 }
    OutJack {
        label: 'noise'
        expression:
            'state := (48271 * state) % 2147483647;
             (ctrlGain + inGain) * (2 * state / 2147483646 - 1)'
    }
}
