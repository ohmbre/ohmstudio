import QtQuick

Module {
    label: 'CV Sequencer'

    InJack {label: 'clock'}
    InJack {label: 'reset'}

    CV { label: 'v1' }
    CV { label: 'v2' }
    CV { label: 'v3' }
    CV { label: 'v4' }
    CV { label: 'v5' }
    CV { label: 'v6' }
    CV { label: 'v7' }
    CV { label: 'v8' }

    Variable {
        label: 'seq'
        value: mapList(cvs, cv => cv.volts)
    }

    OutJack {
        label: 'cv'
        calc: `bool was_hi = false;
               long cnt = 0;
               double calc() {
                   if (reset > 3) cnt = 0;
                   bool hi = clock > 3;
                   double ret = seq[cnt];
                   if (hi && !was_hi)
                       cnt = (cnt + 1) % 8;
                   was_hi = hi;
                   return ret;
               }`
    }
}
