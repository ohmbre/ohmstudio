import ohm 1.0

Module {
    objectName: 'SineVCOModule'
    label: 'Sine VCO'

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
        ExponentialCV {
            label: 'freq'
            inVolts: inStream('v/oct')
            logBase: 2
            from: '440hz'
        },
        LinearCV {
            label: 'gain'
            controlVolts: 3
            inVolts: inStream('gain')
        }
    ]


}
