import ohm 1.0

Module {
    objectName: 'QuantizerModule'
    label: 'Quantizer'
    outJacks: [
        OutJack {
            label: 'v/oct'
            stream: 'floor($input)+list(@scale,10v*mod($input,1))'
        }
    ]
    inJacks: [
        InJack {label: 'input'}
    ]
    cvs: [
        QuantCV {
            label: 'scale'
            choices: ['min','locrian','maj','dorian','phrygian','lydian','mixolydian',
                'minPentatonic','majPentatonic','egyptian','minBlues','majBlues']
        }
    ]
}

