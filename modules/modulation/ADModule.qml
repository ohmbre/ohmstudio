import ohm 1.0

Module {
    objectName: 'ADModule'

    label: 'A/D Envelope'

    outJacks: [
        OutJack {
            label: 'envelope'
            stream: '@offset + @gain*ramps($gate,0v,1v,@attack,@atkshape,0v,@decay,@decshape)'
        }

    ]

    inJacks: [
        InJack {label: 'gain'},
        InJack {label: 'atkshape'},
        InJack {label: 'attack'},
        InJack {label: 'gate'},
        InJack {label: 'decay'},
        InJack {label: 'decshape'},
        InJack {label: 'offset'}
    ]

    cvs: [
        LogScaleCV {
            label: 'attack'
            inVolts: inStream('attack')
            from: '100ms'
        },
        LogScaleCV {
            label: 'decay'
            inVolts: inStream('decay')
            from: '100ms'
        },
        LogScaleCV {
            label: 'atkshape'
            logBase: 4
            inVolts: inStream('atkshape')
            from: 1
        },
        LogScaleCV {
            label: 'decshape'
            logBase: '4'
            inVolts: inStream('decshape')
            from: 1
        },
        LogScaleCV {
            label: 'gain'
            logBase: 1.35
            from: 2
            inVolts: inStream('gain')
        },
        LinearCV {
            label: 'offset'
            from: 0
            inVolts: inStream('offset')
        }
    ]
}
