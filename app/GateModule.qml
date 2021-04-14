Module {

    label: 'Gate'
    
    InJack {label: 'trig'}
    
    InJack {label: 'inHold'}
    CV {
        label: 'ctrlHold'
        translate: v=>500 * 1.3**v
        unit: 'ms'
    }

    OutJack {
        label: 'gate'
        calc: `bool was_hi = false;
               double t = DBL_MAX;
               double calc() {
                   bool hi = trig > 3;
                   if (hi && !was_hi)
                       t = 0;
                   was_hi = hi;
                   return t++ < 500*ms*pow(1.3,inHold+ctrlHold) ? 10 : 0;
               }`
    }

}
