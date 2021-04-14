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
        label: 'triangle'
        calc: `double phase = 0;
               double calc() {
                   phase += 220*Hz * pow(2., ctrlFreq+inFreq);
                   return (inGain+ctrlGain) * (fabs(2.*fmod(phase, tau)/pi - 2) - 1);
               }`
    }
}
