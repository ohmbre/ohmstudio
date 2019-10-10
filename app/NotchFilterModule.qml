import ohm 1.0

Module {

    label: 'Notch Filter'

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
    OutJack {
        label: 'out'
        stateVars: ({x1: 0, x2: 0, y1: 0, y2: 0})
        expression: 'var f := 220hz * 2^(ctrlFreq + inFreq);
                     var sn := sin(f);
                     var q := 1.5^(ctrlQ + inQ);
                     var alpha := sn * sinh(log(2)/2 * f / (sn * q));
                     var m2cs := -2*cos(f);
                     var tmp := clamp(-10, (input + m2cs*x1 + x2 - m2cs*y1 + (alpha-1)*y2) / (1 + alpha), 10);
                     x2 := x1;
                     x1 := input;
                     y2 := y1;
                     y1 := tmp;'
    }
    OutJack {
        label: '24db'
        stateVars: ({x1: 0, x2: 0, y1: 0, y2: 0, u1: 0, u2: 0, v1:0, v2: 0})
        expression: 'var f := 220hz * 2^(ctrlFreq + inFreq);
                     var sn := sin(f);
                     var q := 1.5^(ctrlQ + inQ);
                     var alpha := sn * sinh(log(2)/2 * f / (sn * q));
                     var m2cs := -2*cos(f);
                     var tmp := clamp(-10, (input + m2cs*x1 + x2 - m2cs*y1 + (alpha-1)*y2) / (1 + alpha), 10);
                     x2 := x1;
                     x1 := input;
                     y2 := y1;
                     y1 := tmp;
                     tmp := clamp(-10, (input + m2cs*u1 + u2 - m2cs*v1 + (alpha-1)*v2) / (1 + alpha), 10);
                     u2 := u1;
                     u1 := y1;
                     v2 := v1;
                     v1 := tmp;'
    }

}
