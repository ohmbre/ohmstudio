import ohm 1.0

Module {
    label: 'VCA'

        OutJack {
            label: 'out'

            stream: '(@gain) * ($in + @inshift)'
        }

        InJack {
            label: 'gain'
        }
        InJack {
            label: 'in'
            stream: 5
        }


        LinearCV {
            label: 'gain'
            inVolts: inStream('gain')
        }
        LinearCV {
            label: 'inshift'
        }

}
