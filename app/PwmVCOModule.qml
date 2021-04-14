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
        calc: `double phase = 0;
               double calc() {
                   phase += 220 * Hz * pow(2., ctrlFreq + inFreq);
                   return fmod(phase,tau) < ((ctrlDuty+inDuty)/20 + .5) ? (inGain + ctrlGain) : 0;
               }`
    }
}
