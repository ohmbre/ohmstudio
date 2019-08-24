import ohm 1.0

Module {
    objectName: 'KnobModule'

    label: 'Knob'

    outJacks: [
        OutJack {
            label: 'output'
            stream: '@cv'
        }
    ]

    cvs: [
        LinearCV {
            label: 'cv'
            inVolts: 0
            from: '0v'
        }
    ]
}
