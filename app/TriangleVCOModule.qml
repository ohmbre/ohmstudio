import ohm 1.0

Module {

    label: 'Triangle VCO'
    InJack { label: 'inFreq' }
    InJack { label: 'inGain' }
    CV {
        label: 'ctrlFreq'
        translate: v => 220 * 2**v
        unit: 'Hz'
    }
    CV { label: 'ctrlGain'; volts: 3 }
    OutJack {
        label: 'saw'
        stateVars: ({phase: 0})
        expression: 'phase += 220Hz * 2^(ctrlFreq+inFreq);
                     (inGain+ctrlGain) * (abs(2*(phase % tau)/pi-2) - 1)'
    }
}
