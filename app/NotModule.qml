Module {
    label: 'Not'

    InJack {label: 'input'}

    OutJack {
        label: 'out'
        expression: 'input >= 3 ? 0 : 10'
    }


}
