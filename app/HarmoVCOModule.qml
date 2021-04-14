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

    OutJack {
        label: 'signal'
        calc: `double t = DBL_MAX;
               double phase = 0;
               bool was_hi = false;
               double calc() {
                   bool hi = trig > 3;
                   if (hi && !was_hi)
                       t = 0;
                   was_hi = hi;
                   phase += 220*Hz * pow(2., ctrlFreq + inFreq);
                   return (inGain+ctrlGain) * atan(sin(phase)/(cos(phase)+exp(t++/(200*ms * pow(1.5, inDecay+ctrlDecay)))));
               }`
    }
}
