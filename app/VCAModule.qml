Module {
    label: 'VCA'
    InJack { label: 'inGain' }
    InJack { label: 'inShift' }
    InJack { label: 'input' }
    CV { label: 'ctrlGain' }
    CV { label: 'ctrlShift' }
    OutJack {
        label: 'out'
        calc: `double calc() {
                   return (inGain + ctrlGain) * (input + inShift + ctrlShift);
               }`
    }
}
