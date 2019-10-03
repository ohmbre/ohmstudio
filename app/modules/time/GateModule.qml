import ohm 1.0

Module {

    label: 'Gate'


        OutJack {
            label: 'gate'
            stream: 'stopwatch($trig) < @hold ? (10v) : 0'
        }
        InJack {label: 'trig'}
        InJack {label: 'hold'}

        ExponentialCV {
            label: 'hold'
            from: '0.5s'
            logBase: 1.3
            inVolts: inStream('hold')
        }


}
