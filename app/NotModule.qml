Module {
    label: 'Not'

    InJack {label: 'input'}

    OutJack {
        label: 'out'
        calc: `double calc() {
                   return (input >= 3) ? 0 : 10;
               }`
    }


}
