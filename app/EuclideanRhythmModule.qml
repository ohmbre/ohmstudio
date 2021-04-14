Module {

    label: 'Euclid Rhythm'
    InJack { label: 'clock' }
    InJack { label: 'reset' }
    InJack { label: 'inSteps' }
    InJack { label: 'inPulses' }

    CV {
        label: 'ctrlSteps'
        translate: v => Math.floor(v*1.55+16.5)
        decimals: 0
    }

    CV {
        label: 'ctrlPulses'
        translate: v => Math.floor(v*1.55+16.5)
        decimals: 0
    }
    
    CV {
        label: 'ctrlRotation'
        translate: v => Math.floor(v*1.55+16.5)
        decimals: 0
    }

    OutJack {
        label: 'out'
        calc: `bool was_hi;
               int bucket = 0;
               double t = DBL_MAX;
               double calc() {
                  int pulses = (ctrlPulses+inPulses)*1.55 + 16.5;
                  int steps = (ctrlSteps+inSteps)*1.55 + 16.5;
                  int rot = ctrlRotation*1.55 + 16.5;
                  if (reset > 3) bucket = rot % steps;
                  bool hi = clock > 3;
                  if (hi && !was_hi) {
                     bucket += pulses;
                     if (bucket >= steps) {
                        bucket -= steps;
                        t = 0;
                     }
                  }
                  was_hi = hi;
                  t++;
                  return t < 5*ms ? 10 : 0;
               }`//'
    }

}
