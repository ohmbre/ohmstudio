import ohm 1.0

Module {
    label: 'Sine VCO'

    InJack { label: 'inFreq' }
    InJack { label: 'inGain' }
    CV {
        label: 'ctrlFreq'
        translate: v => 220 * 2**v
        unit: 'Hz'
    }
    CV { label: 'ctrlGain'; volts: 3 }
    OutJack {
        label: 'sinusoid'
        stateVars: ({phase: 0})
        expression: 'phase += 220Hz * 2^(ctrlFreq+inFreq);
                     (inGain + ctrlGain)*sin(phase)'
    }
}
