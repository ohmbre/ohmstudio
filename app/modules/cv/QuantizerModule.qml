import ohm 1.0

Module {
    objectName: 'QuantizerModule'
    label: 'Quantizer'
    outJacks: [
        OutJack {
            label: 'v/oct'
            property var scalenotes:
                scaledict.entries().map(
                    entry=>'cvlist(['+entry.intervals.map(i=>tonal.interval(i).semitones).join(',')+'], $input)')
            stream: `list([${scalenotes.join(',')}],@scale)/12`
        }
    ]
    inJacks: [
        InJack {label: 'input'}
    ]
    cvs: [
        //[...Array(128).keys()].map(midi.midiToNoteName)

        QuantCV {
            label: 'scale'
            choices: scaledict.entries().map(entry=>entry.name)
        }
    ]
}

