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
        translate: v => 1.2**v
    }
    CV {
        label: 'ctrlDecay'
        translate: v => 100 * 1.5**v
        unit: 'ms'
    }
    CV {
        label: 'decShape'
        translate: v => 1.2**v
    }
    CV {
        label: 'ctrlGain';
        volts: 3
    }

    OutJack {
        label: 'envelope'
        calc: `bool was_hi = false;
               double v = 0, t = DBL_MAX;
               double calc() {
                   bool hi = trig > 3;
                   double a = 100*ms * pow(1.5, ctrlAttack + inAttack);
                   double d = 100*ms * pow(1.5, ctrlDecay + inDecay);
                   double as = pow(1.2, atkShape);
                   double ds = pow(1.2, decShape);

                   if (hi && !was_hi) t = 0;
                   if (t < a) v += (1-v)*as / (a-t);
                   else if (t < (a+d)) v -= v*ds / (a+d-t);
                   else v = 0;
                   v = clamp(v, 0., 1.);
                   t++;
                   was_hi = hi;
                   return (inGain + ctrlGain) * v;
               }`
    }
}
