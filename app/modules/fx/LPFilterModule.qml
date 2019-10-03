import ohm 1.0

Module {
    label: 'LP Filter'
    InJack {label: 'input'}
    InJack {label: 'inFreq'}
    InJack {label: 'inQ'}
    CV { label: 'ctrlFreq' }
    CV { label: 'ctrlQ' }
    OutJack {
        label: 'out'
        expression: [
            'var f := 440hz * 2^(ctrlFreq + inFreq)',
            'var cs := cos(f)',
            'var sn := sin(f)',
            'var alpha := sn * sinh(log(2)/2 * f / (sn * 1.5^(ctrlQ + inQ)))',
            'var b1 := 1-cs',
            'var b02 := b1/2',
            'var y := (b02*input + b1*x1 + b02*x2 + 2*cs*y1 + (alpha-1)*y2) / (1 + alpha)',
            'x2 := x1',
            'x1 := input',
            'y2 := y1',
            'y1 := y',
            'y'
        ]
    }

}
