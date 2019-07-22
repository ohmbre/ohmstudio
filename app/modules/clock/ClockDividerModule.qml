import ohm 1.0

Module {
    objectName: 'ClockDividerModule'

    label: 'Clock Divider'

    outJacks: [
        OutJack {
            label: 'clkout'
            stream: 'clkdiv($clkin,@div,@shift)'
        }
    ]

    inJacks: [
        InJack {label: 'div'},
        InJack {label: 'clkin'},
        InJack {label: 'shift'}
    ]

    cvs: [
        LinearCV {
            label: 'div'
            inVolts: inStream('div')
            from: 10
            onControlVoltsChanged: controlVolts = Math.round(controlVolts)
        },
        LinearCV {
            label: 'shift'
            inVolts: inStream('shift')
            from: 0
            onControlVoltsChanged: controlVolts = Math.round(controlVolts)
        }
    ]
}