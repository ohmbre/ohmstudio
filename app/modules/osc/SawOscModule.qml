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
            from: '220hz'
        },
        LinearCV {
            label: 'gain'
            inVolts: inStream('gain')
        }
    ]


}
