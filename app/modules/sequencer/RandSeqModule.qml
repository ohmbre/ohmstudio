import ohm 1.0

Module {
    objectName: 'RandSeqModule'
    label: 'Random Sequencer'

    outJacks: [
        OutJack {
            label: 'v/oct'
            stream: '@octaves * sequence($clock,randsample(@scale,@numnotes,@randseed))'
        }
    ]

    inJacks: [
        InJack {label: 'clock'},
        InJack {label: 'randseed'}
    ]

    cvs: [
        QuantCV {
            label: 'scale'
            choices: ['minor','locrian','major','dorian','phrygian','lydian','mixolydian',
                'minorPentatonic','majorPentatonic','egyptian','minorBlues','majorBlues']
        },
        LogScaleCV {
            label: 'randseed'
            inVolts: inStream('randseed')
            from: '666'
        },
        QuantCV {
            label: 'numnotes'
            choices: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,
                17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]
        },
        LogScaleCV {
            label: 'octaves'
            inVolts: '0'
            from: 1
            logBase: 1.25
        }
    ]

}