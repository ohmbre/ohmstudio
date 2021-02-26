Module {
    label: 'Clock'

    InJack { label: 'inTempo'}

    CV {
        label: 'ctrlTempo'
        translate: v => 120*1.5**v
        unit: 'bpm'
    }

    CV {
        label: 'stepsPerBeat'
        translate: v => Math.round(4*1.1**v)
    }

    Variable { label: 't' }

    OutJack {
        label: 'trig'
        expression: 't := t + 1;
                     t % (mins/120/round(4*1.2^stepsPerBeat) * 1.5^(-inTempo-ctrlTempo)) < 5ms ? 10 : 0'

    }

}
