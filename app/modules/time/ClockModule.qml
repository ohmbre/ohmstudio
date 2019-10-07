import ohm 1.0

Module {
    label: 'Clock'

    InJack { label: 'inTempo'}

    CV {
        label: 'ctrlTempo'
        translate: v => 240*1.5**v
        unit: 'bpm'
    }

    OutJack {
        label: 'trig'
        stateVars: ({t : 0})
        expression: 't := t + 1;
                     t % (mins/240 * 1.5^(-inTempo-ctrlTempo)) < 5ms ? 10 : 0'

    }

}
