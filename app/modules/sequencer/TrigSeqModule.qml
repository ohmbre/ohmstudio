import ohm 1.0

Module {
    objectName: 'TrigSeqModule'
    label: 'Trig Sequencer'

    outJacks: [
        OutJack {
            label: 'trig'
            stream: 'list([@t1,@t2,@t3,@t4,@t5,@t6,@t7,@t8,@t9,@t10,@t11,@t12,@t13,@t14,@t15,@t16,@t17,@t18,@t19,@t20,@t21,@t22,@t23,@t24,@t25,@t26,@t27,@t28,@t29,@t30,@t31,@t32],counter($clock,$reset))'
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
        BinaryCV { label: 't1'; displayLabel: '1' },
        BinaryCV { label: 't2'; displayLabel: '2' },
        BinaryCV { label: 't3'; displayLabel: '3' },
        BinaryCV { label: 't4'; displayLabel: '4' },
        BinaryCV { label: 't5'; displayLabel: '5' },
        BinaryCV { label: 't6'; displayLabel: '6' },
        BinaryCV { label: 't7'; displayLabel: '7' },
        BinaryCV { label: 't8'; displayLabel: '8' },
        BinaryCV { label: 't9'; displayLabel: '9' },
        BinaryCV { label: 't10'; displayLabel: '10' },
        BinaryCV { label: 't11'; displayLabel: '11' },
        BinaryCV { label: 't12'; displayLabel: '12' },
        BinaryCV { label: 't13'; displayLabel: '13' },
        BinaryCV { label: 't14'; displayLabel: '14' },
        BinaryCV { label: 't15'; displayLabel: '15' },
        BinaryCV { label: 't16'; displayLabel: '16' },
        BinaryCV { label: 't17'; displayLabel: '17' },
        BinaryCV { label: 't18'; displayLabel: '18' },
        BinaryCV { label: 't19'; displayLabel: '19' },
        BinaryCV { label: 't20'; displayLabel: '20' },
        BinaryCV { label: 't21'; displayLabel: '21' },
        BinaryCV { label: 't22'; displayLabel: '22' },
        BinaryCV { label: 't23'; displayLabel: '23' },
        BinaryCV { label: 't24'; displayLabel: '24' },
        BinaryCV { label: 't25'; displayLabel: '25' },
        BinaryCV { label: 't26'; displayLabel: '26' },
        BinaryCV { label: 't27'; displayLabel: '27' },
        BinaryCV { label: 't28'; displayLabel: '28' },
        BinaryCV { label: 't29'; displayLabel: '29' },
        BinaryCV { label: 't30'; displayLabel: '30' },
        BinaryCV { label: 't31'; displayLabel: '31' },
        BinaryCV { label: 't32'; displayLabel: '32' },
        BinaryCV {
            label: 'reset'
        }
    ]
}
