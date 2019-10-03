import ohm 1.0

Module {
    label: 'Not'

        OutJack {
            label: 'out'
            stream: '($in >= 3) ? 0 : 10v'
        }

        InJack {label: 'in'}
}
