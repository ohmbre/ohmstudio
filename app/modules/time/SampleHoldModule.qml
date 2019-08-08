import ohm 1.0

Module {
    objectName: 'SampleHoldModule'

    label: 'Sample & Hold'

    outJacks: [
        OutJack {
            label: 'out'
            stream: 'samplehold($signal, $trig)'
        }
    ]

    inJacks: [
        InJack {label: 'signal'},
        InJack {label: 'trig'}
    ]

}
