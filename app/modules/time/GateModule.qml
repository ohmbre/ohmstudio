import ohm 1.0

Module {
    objectName: 'GateModule'

    label: 'Gate'

    outJacks: [
        OutJack {
            label: 'gate'
            stream: 'stopwatch($trig) < @hold ? (10v) : 0'
        }
    ]

    inJacks: [
        InJack {label: 'trig'},
        InJack {label: 'hold'}
    ]

    cvs: [
        ExponentialCV {
            label: 'hold'
            from: '0.5s'
            logBase: 1.3
            inVolts: inStream('hold')
        }
    ]


}