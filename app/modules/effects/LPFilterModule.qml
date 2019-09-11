import ohm 1.0

Module {
    objectName: 'LPFilterModule'

    label: 'LP Filter'

    outJacks: [
        OutJack {
            label: '-12dB/oct'
            stream: 'lopass($in,@f,@q)'
        },
        OutJack {
            label: '-24dB/oct'
            stream: 'lopass(lopass($in,@f,@q),@f,@q)'
        }
    ]

    inJacks: [
        InJack {label: 'in'},
        InJack {label: 'f'},
        InJack {label: 'q'}
    ]

    cvs: [
        LogScaleCV {
            label: 'f'
            from: '220hz'
            logBase: 1.6
            inVolts: inStream('f')
        },
        LogScaleCV {
            label: 'q'
            from: 1.0
            logBase: 2.5
            inVolts: inStream('q')
        }
    ]


}
