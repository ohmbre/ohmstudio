import ohm 1.0

Module {
    objectName: 'SineOscModule'
    label: 'Sine Osc'

    outJacks: [
        OutJack {
            label: 'signal'
            stream: '@gain*sinusoid(@freq)'
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
            from: 3
            logBase: 1.4
        }
    ]


}
