import ohm 1.0

Module {
    label: 'BP Filter'
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

    Variable { label: 'x1' }
    Variable { label: 'x2' }
    Variable { label: 'y1' }
    Variable { label: 'y2' }
    Variable { label: 'u1' }
    Variable { label: 'u2' }
    Variable { label: 'v1' }
    Variable { label: 'v2' }
    Variable { label: 'w1' }
    Variable { label: 'w2' }
    Variable { label: 'z1' }
    Variable { label: 'z2' }


    OutJack {
        label: '12db'
        expression: 'var f := 220hz * 2^(ctrlFreq + inFreq);
                     var sn := sin(f);
                     var q := 1.5^(ctrlQ + inQ);
                     var alpha := sn * sinh(log(2)/2 * f / (sn * q));
                     var tmp := clamp(-10,(alpha*(input - x2 + y2) + 2*cos(f)*y1 - y2) / (1 + alpha),10);
                     x2 := x1;
                     x1 := input;
                     y2 := y1;
                     y1 := tmp;'
    }
    OutJack {
        label: '24db'
        expression: 'var f := 220hz * 2^(ctrlFreq + inFreq);
                     var sn := sin(f);
                     var q := 1.5^(ctrlQ + inQ);
                     var alpha := sn * sinh(log(2)/2 * f / (sn * q));
                     var tmp := clamp(-10,(alpha*(input - u2 + v2) + 2*cos(f)*v1 - v2) / (1 + alpha),10);
                     u2 := u1;
                     u1 := input;
                     v2 := v1;
                     v1 := tmp;
                     tmp := clamp(-10, (alpha*(v1 - w2 + z2) + 2*cos(f)*z1 - z2) / (1 + alpha), 10);
                     w2 := w1;
                     w1 := v1;
                     z2 := z1;
                     z1 := tmp;'
   }


}
