import ohm 1.0

Module {

    label: 'Toggle'

    BinaryCV { label: 'toggle' }

    OutJack {
        label: 'cv'
        expression: 'toggle'
    }

}
