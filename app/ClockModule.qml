Module {
    label: 'Clock'

    InJack { label: 'inTempo'}
    InJack { label: 'reset' }
    
    CV {
        label: 'ctrlTempo'
        translate: v => 120*1.5**v
        unit: 'bpm'
    }

    CV {
        label: 'nSteps'
        translate: v => Math.round(4*1.2**v)
    }

    OutJack {
        label: 'trig'
        calc: `double t = 0;
               double calc() {
                   if (reset > 3) t = 0;
                   return fmod(t++,mins/120/round(4*pow(1.2,nSteps))*pow(1.5,-inTempo-ctrlTempo)) < 5*ms ? 10 : 0;
               }`
    }
}
