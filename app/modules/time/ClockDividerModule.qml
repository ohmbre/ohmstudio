import ohm 1.0

Module {

    label: 'Clock Divider'

    InJack {label: 'inClk'}

    CV {
        label: 'div'
        translate: v => Math.floor(1 + (v+10)/20 * 31.999999)
        decimals: 0
    }
    CV {
        label: 'shift'
        translate: v => Math.floor(.5 + v/20 * 30.999999)
        decimals: 0
    }

    OutJack {
        label: 'outClk'
        stateVars: ({inGate: 0, outGate: 0, count: 0})
        expression:
            'if ((inGate == 0) and (inClk > 3))
             {
                count := count + 1;
                outgate := (count-floor(.5 + v/20 * 30.999999)) % floor(1 + (div+10)/20 * 31.999999) == 0 ? 1 : 0;
                inGate := 1
             }
             else if ((inGate == 1) and (inClk < 3))
             {
                inGate := 0;
                outGate = (outGate == 1) ? 0 : outGate
             };
             outGate == 1 ? 10 : 0'
    }

}
