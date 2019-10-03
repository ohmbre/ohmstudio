import ohm 1.0

Module {
    label: 'Random Sequencer'

        OutJack {
            label: 'v/oct'
            stream: `samplehold(random(@seed,-10,10,@numnotes),$trig)`
        }

        InJack {label: 'trig'}
        InJack {label: 'seed'}
        DiscreteCV {
            label: 'numnotes'
            step: 1
            start: 1
            end: 32
        }

        ExponentialCV {
            label: 'seed'
            inVolts: inStream('seed')
            from: '666'
            logBase: 2
        }



}
