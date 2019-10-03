import ohm 1.0

Module {
    label: 'PWM VCO'
    InJack { label: 'inFreq' }
    InJack { label: 'inDuty' }
    InJack { label: 'inGain' }
    CV { label: 'ctrlFreq' }
    CV { label: 'ctrlDuty' }
    CV { label: 'ctrlGain'; volts: 3 }
    OutJack {
        label: 'pwm'
        expression: [
            'phase += 440Hz * 2^(ctrlFreq+inFreq)',
            '(phase % tau)/tau < ((ctrlDuty+inDuty)/20+0.5) ? (inGain+ctrlGain) : 0'
        ]
    }
}
