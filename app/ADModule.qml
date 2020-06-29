import ohm 1.0

Module {

    label: 'A/D Envelope'
    tags: ['envelope','cv']
    InJack {label: 'trig'}
    InJack {label: 'inGain'}
    InJack {label: 'inAttack'}
    InJack {label: 'inDecay'}
    CV {
        label: 'ctrlAttack'
        translate: v => 100 * 1.5**v
        unit: 'ms'
    }
    CV {
        label: 'atkShape'
        translate: v => 2**v
    }
    CV {
        label: 'ctrlDecay'
        translate: v => 100 * 1.5**v
        unit: 'ms'
    }
    CV {
        label: 'decShape'
        translate: v => 2**v
    }
    CV {
        label: 'ctrlGain';
        volts: 3
    }

    Variable { label: 't' }
    Variable { label: 'gate' }

    OutJack {
        label: 'envelope'
        expression: "
           t := (gate == 0) and (trig > 3) ? 0 : t+1;
           gate := (trig > 3) ? 1 : 0;
           var attack := 100ms * 1.5^(ctrlAttack+inAttack);
           var decay := 100ms * 1.5^(ctrlDecay + inDecay);
           (inGain+ctrlGain) * (t < attack ? (t/attack)^(2^atkShape) : max(0,1-(t-attack)/decay)^(2^decShape))"
    }

}
