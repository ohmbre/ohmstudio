import ohm 1.0

Module {
    objectName: 'SawOscModule'
    label: 'Saw Osc'

    outJacks: [
        OutJack {
            label: 'signal'
            stream: '@gain * sawtooth(@freq)'
        }
    ]

    inJacks: [
        InJack { label: 'v/oct' },
        InJack { label: 'gain' }
    ]

    cvs: [
        LogScaleCV {
            label: 'freq'
            inVolts: inStream('v/oct')
            from: 'notehz(C,4)'
        },
        LogScaleCV {
            label: 'gain'
            inVolts: inStream('gain')
            from: 2
            logBase: 1.38
        }
    ]


}
