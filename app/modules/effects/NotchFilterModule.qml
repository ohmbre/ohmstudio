import ohm 1.0

Module {
    objectName: 'NotchFilterModule'

    label: 'Notch Filter'


    outJacks: [
        OutJack {
            label: '-12dB/oct'
            stream: 'notchfilter($in,@f,@q)'
        },
        OutJack {
            label: '-24dB/oct'
            stream: 'notchfilter(notchfilter($in,@f,@q),@f,@q)'
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
