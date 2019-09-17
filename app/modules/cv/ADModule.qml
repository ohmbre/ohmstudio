import ohm 1.0

Module {
    objectName: 'ADModule'

    label: 'A/D Envelope'

    outJacks: [
        OutJack {
            label: 'envelope'
            stream: `@offset + @gain * (
                        (stopwatch($trig)<@attack) ?
                              (stopwatch($trig)/@attack)^@atkshape :
                              max(0,1-(stopwatch($trig)-@attack)/@decay)^@decshape)`
        }

    ]

    inJacks: [
        InJack {label: 'trig'},
        InJack {label: 'gain'},
        InJack {label: 'offset'},
        InJack {label: 'attack'},
        InJack {label: 'atkshape'},
        InJack {label: 'decay'},
        InJack {label: 'decshape'}
    ]

    cvs: [
        ExponentialCV {
            label: 'attack'
            inVolts: inStream('attack')
            from: '100ms'
            logBase: 1.5
        },
        ExponentialCV {
            label: 'atkshape'
            inVolts: inStream('atkshape')
            from: '1'
        },
        ExponentialCV {
            label: 'decay'
            inVolts: inStream('decay')
            from: '100ms'
            logBase: 1.5
        },
        ExponentialCV {
            label: 'decshape'
            inVolts: inStream('decshape')
            from: '1'
        },
        LinearCV {
            label: 'gain'
            inVolts: inStream('gain')
        },
        LinearCV {
            label: 'offset'
            inVolts: inStream('offset')
        }
    ]
}
