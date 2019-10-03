import ohm 1.0

Module {

    label: 'Sample & Hold'

        OutJack {
            label: 'out'
            stream: 'samplehold($signal, $trig)'
        }
        InJack {label: 'signal'}
        InJack {label: 'trig'}

}
