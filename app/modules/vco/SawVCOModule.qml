import ohm 1.0

Module {
    objectName: 'SawVCOModule'
    label: 'Saw VCO'

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
        ExponentialCV {
            label: 'freq'
            inVolts: inStream('v/oct')
            from: '440hz'
        },
        LinearCV {
            controlVolts: 3
            label: 'gain'
            inVolts: inStream('gain')
        }
    ]


}
