import ohm 1.0

Module {
    objectName: 'RandomNoiseModule'
    label: 'Random Noise'

    outJacks: [
        OutJack {
            label: 'signal'
            stream: '@gain*noise(@coef)'
        }
    ]

    inJacks: [
        InJack { label: 'gain' },
        InJack { label: 'coef' }
    ]

    cvs: [
        LogScaleCV {
            label: 'gain'
            inVolts: inStream('gain')
            from: 2
            logBase: 1.38
        },
        LogScaleCV {
            label: 'coef'
            inVolts: inStream('coef')
            from: 279470273
            logBase: 3
            onControlVoltsChanged: controlVolts = Math.round(controlVolts)
        }
    ]


}
