import ohm 1.0

Module {
    label: 'BP Filter'
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
            'var y := (alpha*(input - x2 + y2) + 2*cos(f)*y1 - y2) / (1 + alpha)',
            'x2 := x1',
            'x1 := input',
            'y2 := y1',
            'y1 := y',
            'y'
        ]
    }
}
