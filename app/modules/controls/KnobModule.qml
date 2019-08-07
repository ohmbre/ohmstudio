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
        LogScaleCV {
            label: 'cv'
            inVolts: 0
            from: '5v'
            logBase: 1.1
        }
    ]
}
