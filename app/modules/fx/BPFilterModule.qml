import ohm 1.0

Module {
    objectName: 'BPFilterModule'

    label: 'BP Filter'

    outJacks: [
        OutJack {
            label: '-12dB/oct'
            stream: 'bandpass($in,@f,@q)'
        },
        OutJack {
            label: '-24dB/oct'
            stream: 'bandpass(bandpass($in,@f,@q),@f,@q)'
        }
    ]

    inJacks: [
        InJack {label: 'in'},
        InJack {label: 'f'},
        InJack {label: 'q'}
    ]

    cvs: [
        ExponentialCV {
            label: 'f'
            from: '220hz'
            logBase: 1.6
            inVolts: inStream('f')
        },
        ExponentialCV {
            label: 'q'
            from: 1.0
            logBase: 2.5
            inVolts: inStream('q')
        }
    ]


}
