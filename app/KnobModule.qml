import ohm 1.0

Module {
    label: 'CV Slider'

    CV { label: 'slider' }
    OutJack {
        label: 'cv'
        expression: 'slider'
    }

}
