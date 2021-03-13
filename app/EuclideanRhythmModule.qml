Module {

    label: 'Euclid Rhythm'
    InJack { label: 'clock' }
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

    Variable { label: 'gate' }
    Variable { label: 'step' }
    Variable { label: 't'; value: 99999999 }
    Variable { label: 'remainder' }
    Variable { label: 'a' }
    Variable { label: 'b' }
    Variable { label: 'count' }

    OutJack {
        label: 'out'
        expression:
            'var pulses := floor((ctrlPulses+inPulses)*1.55+16.5);
             var steps := floor((ctrlSteps+inSteps)*1.55+16.5);
             if ((gate == 0) and (clock > 3))
             {
                if (step == 0) {
                  remainder := (steps - pulses) % pulses;
                  a := ((remainder == 0) or (floor(pulses/remainder) == 0)) ? 0 : floor((pulses-remainder)/floor(pulses/remainder));
                  b := 0;
                  count := 0;
                };
                step := (step + 1) % steps;
                if (count == 0) {
                  t := 0;
                  count := floor((steps-pulses)/pulses);
                  if ((remainder > 0) and (b == 0)) {
                    count := count + 1;
                    remainder := remainder - 1;
                    var wobble := (steps - pulses)%pulses;
                    b := ((a > 0) or (wobble == 0)) ? 0 : floor(pulses/wobble);
                    a := a - 1;
                  }
                  else {
                    b := b - 1;
                  };
                }
                else
                {
                  count := count - 1;
                };
             };
             gate := (clock > 3) ? 1 : 0;
             t := t + 1;
             (t <= 5ms) ? 10 : 0'
    }

}
