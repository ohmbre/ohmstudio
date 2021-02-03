import ohm 1.0
import QtQuick

Module {
    label: "Delay"

    InJack { label: 'signal' }
    InJack { label: 'inDelay' }

    CV {
        label: 'ctrlDelay'
        translate: v => 200 * 10**(v/10)
        unit: 'ms'
    }
    Variable { label: 'pos'; }
    Variable { label: 'history'; value: Array(FRAMES_PER_SEC*2).fill(0); }
    OutJack {
        label: 'delayed'
        expression:
            'var ret := 0;
             ret := history[pos];
             history[pos] := signal;
             pos := (pos + 1) % round(200ms*10^((inDelay+ctrlDelay)/10));
             ret'
    }

}
