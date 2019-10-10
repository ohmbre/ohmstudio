import ohm 1.0

Module {
    label: 'PWM VCO'
    InJack { label: 'inFreq' }
    InJack { label: 'inDuty' }
    InJack { label: 'inGain' }
    CV {
        label: 'ctrlFreq'
        translate: v => 220 * 2**v
        unit: 'Hz'
    }
    CV { label: 'ctrlDuty' }
    CV { label: 'ctrlGain'; volts: 3 }
    OutJack {
        label: 'pwm'
        stateVars: ({phase: 0})
        expression: 'phase += 220Hz * 2^(ctrlFreq+inFreq);
                     (phase % tau)/tau < ((ctrlDuty+inDuty)/20+0.5) ? (inGain+ctrlGain) : 0'
    }
}
