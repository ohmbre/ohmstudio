Module {
    label: 'Knob'

    CV { label: 'volts' }
    OutJack {
        label: 'cv'
        calc: `double calc() {
                   return volts;
               }`
    }

}
