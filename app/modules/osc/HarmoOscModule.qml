import ohm 1.0

Module {
    objectName: 'HarmoOscModule'
    label: 'Harmo Osc'

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
        LogScaleCV {
            label: 'freq'
            inVolts: inStream('v/oct')
            from: '220hz'
        },
        LinearCV {
            label: 'gain'
            inVolts: inStream('gain')
        },
        LogScaleCV {
            label: 'decay'
            inVolts: inStream('decay')
            from: .0001
            logBase: 2
        }
    ]


}
