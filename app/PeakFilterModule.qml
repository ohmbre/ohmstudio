Module {
    id: filter
    label: 'Peak Filter'
    tags: ['filter','fx']

    InJack {label: 'input'}
    InJack {label: 'inFreq'}
    InJack {label: 'inQ'}
    CV {
        label: 'ctrlFreq'
        translate: v => 220 * 2**v
        unit: 'Hz'
    }
    CV {
        label: 'ctrlQ'
        translate: v => 1.5**v
    }

    property string commonCalc:
        `struct State { double x1; double x2; double y1; double y2; };
         double f=0, adivg=0, ag=0, b1 = 0;
         double next(double v,struct State *s) {
             double tmp = (1+ag)*v + b1*(s->x1 - s->y1) + (1-ag)*s->x2 - (1-adivg)*s->y2;
             s->x2 = s->x1;
             s->x1 = v;
             s->y2 = s->y1;
             s->y1 = clamp(tmp/(1+adivg), -10., 10.);
             return s->y1;
         }
         void calcParam() {
             f = 220*Hz * pow(2, ctrlFreq + inFreq);
             double q = pow(1.5, ctrlQ+inQ);
             double a = sin(f)*sinh(log(2)/2 * f/(sin(f)*q));
             adivg = a / q;
             ag = a*q;
             b1 = -2*cos(f);
         }`//'
    
    OutJack {
        label: '12db'
        calc: filter.commonCalc + `
               struct State state = {0,0,0,0};
               double calc() {
                   calcParam();
                   return next(input,&state);
               }`//'
    }
        
    OutJack {
        label: '24db'
        calc: filter.commonCalc + `
               struct State state1 = {0,0,0,0}, state2 = {0,0,0,0};
               double calc() {
                   calcParam();
                   return next(next(input, &state1), &state2);
               }`//'
    }

}
