import ohm 1.0

Module {

    label: 'Clock Divider'

    InJack {label: 'inClk'}

    CV {
        label: 'div'
        translate: v => Math.floor(1 + (v+10)/20 * 31.999999)
        decimals: 0
        volts: -7
    }
    CV {
        label: 'shift'
        translate: v => Math.floor((v+10)/20 * 31.999999)
        decimals: 0
        volts: -10
    }
    Variable { label: 'inGate' }
    Variable { label: 'outGate' }
    Variable { label: 'count' }
    OutJack {
        label: 'outClk'
        expression:
            'var iDiv := floor(1 + (div+10)/20 * 31.999999);
             var iShift := floor((shift+10)/20 * 31.999999);
             count := (inGate == 0) and (inClk > 3) ? (count + 1) % 32 : count;
             outGate := (inGate == 0) and (inClk > 3) and ((count + iShift) % iDiv == 0) ? 1 : (inClk == 0 ? 0 : outGate);
             inGate := (inClk > 3) ? 1 : 0;
             outGate == 1 ? 10 : 0'
    }

}
