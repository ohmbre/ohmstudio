import ohm 1.0

Module {
    objectName: 'RandSeqModule'
    label: 'Random Sequencer'

    outJacks: [
        OutJack {
            label: 'v/oct'
            stream: `samplehold(random(@seed,-10,10,@numnotes),$trig)`
        }
    ]

    inJacks: [
        InJack {label: 'trig'},
        InJack {label: 'seed'}
    ]

    cvs: [
        DiscreteCV {
            label: 'numnotes'
            step: 1
            start: 1
            end: 32
        },

        ExponentialCV {
            label: 'seed'
            inVolts: inStream('seed')
            from: '666'
            logBase: 2
        }

    ]

}
