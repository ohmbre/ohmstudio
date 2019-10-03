import QtQuick 2.12
import ohm 1.0

Module {
    label: 'CV Sequencer'


        OutJack {
            label: 'v/oct'
            stream: 0
        }



        InJack {label: 'clock'}
        InJack {label: 'randseed'}


       MultiLogCV {
         label: 'sequence'
       }
       ExponentialCV {
         label: 'octave'
       }
       BinaryCV {
         label: 'flipper'
       }

}
