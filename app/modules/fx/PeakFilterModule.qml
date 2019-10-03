import ohm 1.0

Module {
    label: 'Peak Filter'

    InJack {label: 'input'}
    InJack {label: 'inFreq'}
    InJack {label: 'inQ'}
    CV { label: 'ctrlFreq' }
    CV { label: 'ctrlQ' }
    OutJack {
        label: 'out'
        expression: [
            'var f := 440hz * 2^(ctrlFreq + inFreq)',
            'var sn := sin(f)',
            'var alpha := sn * sinh(log(2)/2 * f / (sn * 1.5^(ctrlQ + inQ)))',
            'var adivg := alpha/q',
            'var ag := alpha*q',
            'var b1 = -2*cos(f)',
            'var y := ((1+ag)*x + b1*(x1-y1) + (1-ag)*x2 - (1-adivg)*y2)/(1+adivg)',
            'x2 := x1',
            'x1 := input',
            'y2 := y1',
            'y1 := y',
            'y'
        ]
    }



}
