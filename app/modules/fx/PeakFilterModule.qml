import ohm 1.0

Module {
    objectName: 'PeakFilterModule'

    label: 'Peak Filter'

    outJacks: [
        OutJack {
            label: '-12dB/oct'
            stream: 'peakfilter($in,@f,@q,@gain)'
        },
        OutJack {
            label: '-24dB/oct'
            stream: 'peakfilter(peakfilter($in,@f,@q,@gain),@f,@q,@gain)'
        }
    ]

    inJacks: [
        InJack {label: 'in'},
        InJack {label: 'f'},
        InJack {label: 'q'},
        InJack {label: 'gain'}
    ]

    cvs: [
        ExponentialCV {
            label: 'f'
            from: '200hz'
            logBase: 1.6
            inVolts: inStream('f')
        },
        ExponentialCV {
            label: 'q'
            from: 1.0
            logBase: 2.5
            inVolts: inStream('q')
        },
        ExponentialCV {
            label: 'gain'
            from: 1.0
            logBase: 2.5
            inVolts: inStream('gain')
        }

    ]


}
