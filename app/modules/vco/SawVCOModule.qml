import ohm 1.0

Module {

    label: 'Saw VCO'
    InJack { label: 'inFreq' }
    InJack { label: 'inGain' }
    CV { label: 'ctrlFreq' }
    CV { label: 'ctrlGain'; volts: 3 }
    OutJack {
        label: 'saw'
        expression: [
            'phase += 440Hz * 2^(ctrlFreq+inFreq)',
            '(inGain+ctrlGain) * ((phase % tau)/pi - 1)'
        ]
    }
}
