import ohm 1.0

Module {
    objectName: 'VCAModule'
    label: 'VCA'

    outJacks: [
        OutJack {
            label: 'out'

            stream: '(@gain) * ($in + @inshift)'
        }
    ]

    inJacks: [
        InJack {
            label: 'gain'
        },
        InJack {
            label: 'in'
            stream: 5
        }
    ]

    cvs: [
        LogScaleCV {
            label: 'gain'
            inVolts: inStream('gain')
            from: 1
            logBase: 1.6
        },
        LinearCV {
            label: 'inshift'
            from: 0
        }

    ]
}
