import ohm 1.0

Module {
    objectName: 'TrigSeqModule'
    label: 'Trig Sequencer'

    outJacks: [
        OutJack {
            label: 'trig'
            stream: 'list([@t1,@t2,@t3,@t4,@t5,@t6,@t7,@t8],10*mod(counter($clock,$reset),8)/8)'
        },
        OutJack {
            label: 'reset'
            stream: '@reset'
        }
    ]

    inJacks: [
        InJack {label: 'clock'},
        InJack {label: 'reset'}
    ]

    cvs: [
        BinaryCV {
            label: 't1'
        },
        BinaryCV {
            label: 't2'
        },
        BinaryCV {
            label: 't3'
        },
        BinaryCV {
            label: 't4'
        },
        BinaryCV {
            label: 't5'
        },
        BinaryCV {
            label: 't6'
        },
        BinaryCV {
            label: 't7'
        },
        BinaryCV {
            label: 't8'
        },
        BinaryCV {
            label: 'reset'
        }
    ]
}
