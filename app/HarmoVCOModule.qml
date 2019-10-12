import ohm 1.0

Module {

    label: 'Harmo VCO'

    InJack { label: 'trig' }
    InJack { label: 'inFreq' }
    InJack { label: 'inGain' }
    InJack { label: 'inDecay' }

    CV {
        label: 'ctrlFreq'
        translate: v => 220 * 2**v
        unit: 'Hz'
    }
    CV {
        label: 'ctrlGain'
        volts: 3
    }
    CV {
        label: 'ctrlDecay'
        translate: v => 200 * 1.5**v
        unit: 'ms'
    }
    Variable { label: 'phase' }
    Variable { label: 't'; value: 99999999 }
    Variable { label: 'gate' }
    OutJack {
        label: 'signal'
        expression:
            't := (gate == 0) and (trig > 3) ? 0 : t + 1;
             gate := trig > 3 ? 1 : 0;
             phase += 220Hz * 2^(ctrlFreq+inFreq);
             (inGain+ctrlGain)*atan(sin(phase)/(cos(phase)+exp(t/(200ms * 1.5^(inDecay + ctrlDecay)))))'
    }
}
