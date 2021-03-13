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
    Variable { label: 'history'; value: Array(AUDIO_OUT.sampleRate()*2).fill(0); }
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
