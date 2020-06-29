import ohm 1.0

Module {

    label: 'ADSR Envelope'
    tags: ['envelope','cv']

    InJack {label: 'trig'}
    InJack {label: 'inGain'}
    InJack {label: 'inAttack'}
    InJack {label: 'inDecay'}
    InJack {label: 'inSustain'}
    InJack {label: 'inRelease'}

    CV {
        label: 'ctrlAttack'
        translate: v => 100 * 1.5**v
        unit: 'ms'
    }
    CV {
        label: 'ctrlDecay'
        translate: v => 100 * 1.5**v
        unit: 'ms'
    }
    CV {
        label: 'ctrlSustain'
        translate: v => v*5 + 50
        unit: '%'
    }

    CV {
        label: 'ctrlRelease'
        translate: v => 100 * 1.5**v
        unit: 'ms'
    }
    CV {
        label: 'ctrlGain';
        volts: 3
    }

    Variable { label: 'attack' }
    Variable { label: 'decay' }
    Variable { label: 'sustaining' }
    Variable { label: 'release' }
    Variable { label: 'state' }
    Variable { label: 'gate' }

    OutJack {
        label: 'envelope'
        expression:
            'var sustain := (ctrlSustain + inSustain + 10) / 20;
             if ((gate == 0) and (trig > 3))
             {
                 attack := 100ms * 1.5^(ctrlAttack+inAttack);
                 decay := 100ms * 1.5^(ctrlDecay+inDecay);
                 sustaining := 1
                 release := 100ms * 1.5^(ctrlRelease+inRelease);
             };
             if ((gate == 1) and (trig < 3))
             {
                 attack := 0;
                 decay := 0;
                 sustaining := 0;
             };
             gate := (trig > 3) ? 1 : 0;
             if (attack > 0)
             {
                state := state + (1 - state)/attack;
                attack := attack - 1;
             }
             else if (decay > 0)
             {
                state := state + (sustain - state) / decay;
                decay := decay - 1;
             }
             else if (sustaining == 0 and release > 0)
             {
                state := state - state / release;
                release := release - 1;
             };
             (inGain+ctrlGain) * state'
    }

}
