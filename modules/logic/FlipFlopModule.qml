import ohm 1.0

Module {
    objectName: 'FlipFlopModule'

    label: 'Flip Flop'

    outJacks: [
        OutJack {
            label: 'out'
            stream: 'sequence($trig,[0v,10v])'
        }
    ]

    inJacks: [
        InJack {label: 'trig'}
    ]
}
