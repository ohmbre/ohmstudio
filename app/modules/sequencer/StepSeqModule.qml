import ohm 1.0

Module {
    objectName: 'StepSeqModule'
    label: 'Step Sequencer'

    outJacks: [
        OutJack {
            label: 'v/oct'
            stream: 0
        }
    ]

    inJacks: [
        InJack {label: 'clock'},
        InJack {label: 'randseed'}
    ]

    cvs: [
       MultiLogCV {
         label: 'sequence'
       },
       LogScaleCV {
         label: 'octave'
       },
       BinaryCV {
         label: 'flipper'
       }
    ]

}
