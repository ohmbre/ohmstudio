import QtQuick 2.15
import ohm 1.0

Module {
    label: 'CV Sequencer'

    InJack {label: 'clock'}
    InJack {label: 'reset'}

    CV { label: '1' }
    CV { label: '2' }
    CV { label: '3' }
    CV { label: '4' }
    CV { label: '5' }
    CV { label: '6' }
    CV { label: '7' }
    CV { label: '8' }

    Variable {
        label: 'seq'
        value: mapList(cvs, cv => cv.volts)
    }
    Variable { label: 'gate' }
    Variable { label: 'count' }

    OutJack {
        label: 'cv'
        expression:
            'count := reset > 3 ? 0 : ((gate == 0) and (clock > 3) ? (count + 1) % 8 : count);
             gate := clock > 3 ? 1 : 0;
             seq[count]'
    }





}
