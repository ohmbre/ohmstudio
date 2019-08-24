import ohm 1.0

Module {
    objectName: 'RandSeqModule'
    label: 'Random Sequencer'

    outJacks: [
        OutJack {
            label: 'v/oct'
            stream: 'samplehold(random(@seed,0,@octaves,@numnotes), $trig)'
        }
    ]

    inJacks: [
        InJack {label: 'trig'},
        InJack {label: 'seed'}
    ]

    cvs: [
        LogScaleCV {
            label: 'seed'
            inVolts: inStream('seed')
            from: '666'
            logBase: 2
        },
        QuantCV {
            label: 'numnotes'
            choices: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]
        },
        LogScaleCV {
            label: 'octaves'
            inVolts: '0'
            from: 1
            logBase: 1.25
        }
    ]

}
