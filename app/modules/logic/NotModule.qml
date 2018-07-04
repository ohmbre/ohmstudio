import ohm 1.0

Module {
    objectName: 'NotModule'

    label: 'Not'

    outJacks: [
        OutJack {
            label: 'out'
            stream: '($in >= 3) ? 0 : 10v'
        }
    ]

    inJacks: [
        InJack {label: 'in'}
    ]
}
