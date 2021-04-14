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
        calc: `double calc() {
                   int sign = input < 0 ? -1 : 1;
                   int whole = fabs(input);
                   double frac = fabs(input) - whole;
                   int idx = round((intervals.size()-1) * frac);
                   return sign*((double)whole + intervals[idx] / 12.); 
               }`
    }

}

