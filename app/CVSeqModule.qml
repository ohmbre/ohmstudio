import QtQuick 2.12
import ohm 1.0

Module {
    label: 'CV Sequencer'

    InJack {label: 'clock'}

    CV { label: 'step1' }
    CV { label: 'step2' }
    CV { label: 'step3' }
    CV { label: 'step4' }
    CV { label: 'step5' }
    CV { label: 'step6' }
    CV { label: 'step7' }
    CV { label: 'step8' }

    OutJack {
        label: 'cv'
    }





}
