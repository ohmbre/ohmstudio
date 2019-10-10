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
        label: 'gain'
        volts: 3
    }
    CV {
        label: 'ctrlDecay'
        translate: v => 200 * 2**v
        unit: 'ms'
    }

    OutJack {
        label: 'signal'
        stateVars: ({phase: 0, t: 9999999, gate: 0})
        expression:
            't := (gate == 0) and (trig > 3) ? 0 : t + 1;
             gate := trig > 3 ? 1 : 0;
             phase += 220Hz * 2^(ctrlFreq+inFreq);
             atan(sin(phase)/(cos(phase)+exp(200ms * 2^(inDecay + ctrlDecay) * t)))'
    }
}
