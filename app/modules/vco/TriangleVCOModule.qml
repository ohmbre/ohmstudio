import ohm 1.0

Module {

    label: 'Triangle VCO'
    InJack { label: 'inFreq' }
    InJack { label: 'inGain' }
    CV { label: 'ctrlFreq' }
    CV { label: 'ctrlGain'; volts: 3 }
    OutJack {
        label: 'saw'
        expression: [
            'phase += 440Hz * 2^(ctrlFreq+inFreq)',
            '(inGain+ctrlGain) * (abs(2*(phase % tau)/pi-2) - 1)'
        ]
    }
}
