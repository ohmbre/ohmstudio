Module {
    label: 'VCA'
    InJack { label: 'inGain' }
    InJack { label: 'inShift' }
    InJack { label: 'input' }
    CV { label: 'ctrlGain' }
    CV { label: 'ctrlShift' }
    OutJack {
        label: 'out'
        expression: '(inGain + ctrlGain) * (input + inShift + ctrlShift)'
    }
}
