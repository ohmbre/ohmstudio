import ohm 1.0

Module {

    label: 'Clock Divider'

        OutJack {
            label: 'clkout'
            stream: 'clkdiv($clkin,@div,@shift)'
        }

        InJack {label: 'div'}
        InJack {label: 'clkin'}
        InJack {label: 'shift'}

        LinearCV {
            label: 'div'
            inVolts: inStream('div')
            offset: 11
            onControlVoltsChanged: volts = Math.round(volts)
        }
        LinearCV {
            label: 'shift'
            inVolts: inStream('shift')
            offset: 0
            onControlVoltsChanged: volts = Math.round(volts)
        }

}
