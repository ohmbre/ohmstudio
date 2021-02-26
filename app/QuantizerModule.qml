Module {
    label: 'Quantizer'

    InJack {label: 'input'}

    QuantCV {
        label: 'scale'
        choices: scaledict.entries().map(entry=>entry.name)
    }

    Variable {
        label: 'intervals'
        value: scaledict.entries().map(entry=>entry.intervals.map(i=>tonal.interval(i).semitones))[Math.round(cv('scale').volts)]
    }
    OutJack {
        label: 'quantized'
        expression: 'var whole := (input < 0) ? (ceil(input)-1) : floor(input);
                     var part := (input < 0) ? (frac(input)+1) : frac(input);
                     whole + intervals[floor(intervals[] * part)] / 12'
    }

}

