Module {

    label: 'ADSR Envelope'
    tags: ['envelope','cv']

    InJack {label: 'gate'}
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
    
    OutJack {
        label: 'envelope'
        calc:`bool was_hi = false, sustaining = false;
              double state = 0, t = DBL_MAX;
              double calc() {
                  bool hi = gate > 3;
                  double attack = 100*ms * pow(1.5, ctrlAttack+inAttack);
                  double decay = 100*ms * pow(1.5, ctrlDecay+inDecay);
                  double sustain = (ctrlSustain + inSustain + 10.) / 20.;
                  double release = 100*ms * pow(1.5, ctrlRelease+inRelease);
                  if (hi && !was_hi) {
                      t = 0;
                      sustaining = true;
                  } else if (!hi && was_hi) {
                      t = attack + decay;
                      sustaining = false;
                  }
                  if (t < attack)
                      state += (1-state)/(attack - t++);
                  else if (t < (attack+decay))
                      state += (sustain - state) / (attack+decay - t++);                      
                  else if (!sustaining && (t < (attack+decay+release)))
                      state -= state / (attack+decay+release - t++);
                  state = clamp(state,0.,1.);
                  was_hi = hi;
                  return (inGain+ctrlGain) * state;
             }`
    }

}
