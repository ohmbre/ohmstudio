import ohm 1.0

Module {
    objectName: 'ClockModule'

    label: 'Clock'

    outJacks: [
        OutJack {
            label: 'trig'
            stream: 'smaller(mod(t,(1/@tempo)),10ms) ? (10v) : 0'
        }
    ]

    inJacks: [
        InJack {label: 'tempo'}
    ]

    cvs: [
        ExponentialCV {
            logBase: 1.2
            label: 'tempo'
            inVolts: inStream('tempo')
            from: '240/mins'
        }
    ]
}
