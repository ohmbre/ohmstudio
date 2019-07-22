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
            from: 'notehz(C,4)'
        },
        LogScaleCV {
            label: 'gain'
            inVolts: inStream('gain')
            from: 1.273
            logBase: 1.38
        },
	LogScaleCV {
            label: 'decay'
            inVolts: inStream('decay')
            from: .0001
            logBase: 2
        }
    ]


}
