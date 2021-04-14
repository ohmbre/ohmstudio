Module {

    label: 'Clock Divider'

    InJack {label: 'clock'}
    InJack {label: 'reset'}
    

    CV {
        label: 'ctrlDiv'
        translate: v => Math.floor(1.55*v+16.5)
        decimals: 0
        volts: 0
    }
    CV {
        label: 'ctrlShift'
        translate: v => Math.floor(1.55*v+.5)
        decimals: 0
        volts: 0
    }
    OutJack {
        label: 'clockDiv'
        calc: `int cnt = 0;
               bool clock_was_hi = false, out_hi = false;
               double calc() {
                   int div = 1.55*ctrlDiv + 16.5;
                   int shift = 1.55*ctrlShift + .5;
                   bool clock_hi = clock > 3;
                   if (reset > 3) cnt = 0;
                   if (div <= 1) div = 1;
                   shift = (shift+1) % div;
                   if (clock_hi && !clock_was_hi) {
                       cnt = (cnt + 1) % div;
                       out_hi = (cnt == shift);
                   }
                   out_hi &= clock_hi;
                   clock_was_hi = clock_hi;
                   return out_hi ? 10 : 0;
               }`
    }

}
