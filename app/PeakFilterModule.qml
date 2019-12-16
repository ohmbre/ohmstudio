import ohm 1.0

Module {
    label: 'Peak Filter'

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
                     var adivg := alpha / q;
                     var ag := alpha * q;
                     var b1 := -2*cos(f);
                     var tmp := clamp(-10, ((1+ag)*input + b1*(x1-y1) + (1-ag)*x2 - (1-adivg)*y2)/(1+adivg), 10);
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
                     var adivg := alpha / q;
                     var ag := alpha * q;
                     var b1 := -2 * cos(f);
                     var tmp := clamp(-10, ((1+ag)*input + b1*(u1-v1) + (1-ag)*u2 - (1-adivg)*v2)/(1+adivg), 10);
                     u2 := u1;
                     u1 := input;
                     v2 := v1;
                     v1 := tmp;
                     tmp := clamp(-10, ((1+ag)*v1 + b1*(w1-z1) + (1-ag)*w2 - (1-adivg)*z2)/(1+adivg), 10);
                     w2 := w1;
                     w1 := v1;
                     z2 := z1;
                     z1 := tmp;'
    }



}
