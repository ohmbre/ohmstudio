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
        LinearCV {
            label: 'gain'
            inVolts: inStream('gain')
        },
        LinearCV {
            label: 'inshift'
        }

    ]
}
