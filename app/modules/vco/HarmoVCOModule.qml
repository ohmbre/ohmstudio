import ohm 1.0

Module {
    objectName: 'HarmoVCOModule'
    label: 'Harmo VCO'

    outJacks: [
        OutJack {
            label: 'signal'
            stream: '@gain * sawsin(@freq,@decay,stopwatch($trig))'
        }
    ]

    inJacks: [
        InJack { label: 'v/oct' },
        InJack { label: 'gain' },
        InJack { label: 'trig' },
        InJack { label: 'decay' }
    ]

    cvs: [
        ExponentialCV {
            label: 'freq'
            inVolts: inStream('v/oct')
            from: '440hz'
        },
        LinearCV {
            label: 'gain'
            controlVolts: 3
            inVolts: inStream('gain')
        },
        ExponentialCV {
            label: 'decay'
            inVolts: inStream('decay')
            from: .0001
            logBase: 2
        }
    ]


}
