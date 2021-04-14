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
        translate: v => 3**v
    }

    OutJack {
        label: 'LowPass'
        calc: expression('lp')
    }
        
    OutJack {
        label: 'BandPass'
        calc: expression('bp')
    }
        
    OutJack {
        label: 'HiPass'
        calc: expression('hp')
    }
        
    OutJack {
        label: 'Notch'
        calc: expression('np')
    }   

    function expression(retvar) {
        return `double lp=0, bp=0, hp=0, np=0;
                double calc() {
                    double f = 220*Hz * pow(2.0, ctrlFreq + inFreq);
                    double q = 1.0/pow(3., ctrlQ + inQ);
                    hp = clamp(input - lp - q*bp, -10., 10.);
                    bp = clamp(bp + f*hp, -10., 10.);
                    lp = clamp(lp + f*bp, -10., 10.);
                    np = clamp(lp + hp, -10., 10.);
                    return ${ retvar };
                }`
    }
    

}
