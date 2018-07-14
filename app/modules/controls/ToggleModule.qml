import ohm 1.0

Module {
    objectName: 'ToggleModule'

    label: 'Toggle'

    outJacks: [
        OutJack {
            label: 'gateout'
            stream: '@toggle'
        }
    ]

    cvs: [
        BinaryCV {
            label: 'toggle'
            inVolts: 0
        }
    ]
}
