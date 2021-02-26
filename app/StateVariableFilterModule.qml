Module {
    label: 'SV Filter'
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
        translate: v => 1.2**v
    }
    Variable { label: 'lp' }
    Variable { label: 'bp' }
    Variable { label: 'hp' }
    Variable { label: 'np' }

    property string setup:
        'var f := 220hz * 2^(ctrlFreq + inFreq);
         var q := 1.2^(ctrlQ + inQ);
         hp := clamp(-10,input - lp - q*bp,10);
         bp += clamp(-10,f*hp,10);
         lp += clamp(-10,f*bp,10);
         np := clamp(-10,lp + hp,10);
        '

    OutJack {
        label: 'LowPass'
        expression: setup + 'lp'
    }
    OutJack {
        label: 'BandPass'
        expression: setup + 'bp'
    }
    OutJack {
        label: 'HiPass'
        expression: setup + 'hp'
    }
    OutJack {
        label: 'Notch'
        expression: setup + 'np'
    }



}
