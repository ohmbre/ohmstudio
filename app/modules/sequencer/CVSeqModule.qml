import QtQuick 2.12
import ohm 1.0

Module {
    label: 'CV Sequencer'

    InJack {label: 'clock'}
    InJack {label: 'randseed'}

    CV {
        label: 'sequence'
    }

    CV {
        label: 'flipper'
    }

    OutJack {
        label: 'v/oct'
        stream: 0
    }





}
