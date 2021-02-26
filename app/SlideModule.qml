Module {

    label: 'Slide'

    InJack {label: 'input'}
    InJack {label: 'inRise'}
    InJack {label: 'inFall'}

    CV {
        label: 'ctrlRise'
        translate: v => 200*1.5**v
        unit: 'ms'
    }
    CV {
        label: 'ctrlFall'
        translate: v => 200*1.5**v
        unit: 'ms'
    }
    Variable { label: 'state' }
    OutJack {
        label: 'output'
        expression: 'state := state + (input-state)/(200*1.5^(input > state ? (inRise+ctrlRise) : (inFall+ctrlFall)))'
    }



}

