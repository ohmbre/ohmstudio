Module {

    label: 'Slide'

    InJack {label: 'input'}
    InJack {label: 'inRise'}
    InJack {label: 'inFall'}

    CV {
        label: 'ctrlRise'
        translate: v => 150*1.7**v
        unit: 'ms'
    }
    CV {
        label: 'ctrlFall'
        translate: v => 150*1.7**v
        unit: 'ms'
    }

    OutJack {
        label: 'output'
        calc: `double state = 0.;
               double calc() {
                   double speed = input > state ? (inRise + ctrlRise) : (inFall + ctrlFall);
                   state += (input - state) / (150. * pow(1.7, speed));
                   state = clamp(state,-10.,10.);
                   return state;
               }`
    }



}

