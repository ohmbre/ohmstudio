import ohm 1.0

Module {

    label: 'Mix'

    InJack { label: 'ch1' }
    InJack { label: 'ch2' }
    InJack { label: 'ch3' }
    InJack { label: 'ch4' }
    InJack { label: 'ch5' }
    InJack { label: 'ch6' }
    InJack { label: 'ch7' }
    InJack { label: 'ch8' }

    CV { label: 'gain1'; volts: 1 }
    CV { label: 'gain2'; volts: 1 }
    CV { label: 'gain3'; volts: 1 }
    CV { label: 'gain4'; volts: 1 }
    CV { label: 'gain5'; volts: 1 }
    CV { label: 'gain6'; volts: 1 }
    CV { label: 'gain7'; volts: 1 }
    CV { label: 'gain8'; volts: 1 }

    OutJack {
        label: 'out'
        expression: 'gain1*ch1 + gain2*ch2 + gain3*ch3 + gain4*ch4 + gain5*ch5 + gain6*ch6 + gain7*ch7 + gain8*ch8'
    }

}
