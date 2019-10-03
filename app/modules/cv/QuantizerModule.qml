import ohm 1.0

Module {
    label: 'Quantizer'

        OutJack {
            label: 'v/oct'
            property var scalenotes:
                scaledict.entries().map(
                    entry=>'cvlist(['+entry.intervals.map(i=>tonal.interval(i).semitones).join(',')+'], $input)')
            stream: `list([${scalenotes.join(',')}],@scale)/12`
        }
        InJack {label: 'input'}

        QuantCV {
            label: 'scale'
            choices: scaledict.entries().map(entry=>entry.name)
        }

}

