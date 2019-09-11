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
            logBase: 1.598743737
            from: '220hz'
        },
        LinearCV {
            label: 'gain'
            inVolts: inStream('gain')
        }
    ]


}
