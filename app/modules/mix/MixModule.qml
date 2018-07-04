import ohm 1.0

Module {
    objectName: 'MixModule'
    label: 'Mixer'

    outJacks: [
        OutJack {
            label: 'out'
            stream: '($in1 + $in2)/2'
        }
    ]

    inJacks: [
        InJack {
            label: 'in1'
        },
        InJack {
            label: 'in2'
        }
    ]

}
