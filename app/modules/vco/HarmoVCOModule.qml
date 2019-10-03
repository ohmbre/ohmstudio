import ohm 1.0

Module {

    label: 'Harmo VCO'
        OutJack {
            label: 'signal'
            stream: '@gain * sawsin(@freq,@decay,stopwatch($trig))'
        }
        InJack { label: 'v/oct' }
        InJack { label: 'gain' }
        InJack { label: 'trig' }
        InJack { label: 'decay' }
        ExponentialCV {
            label: 'freq'
            inVolts: inStream('v/oct')
            from: '440hz'
        }
        LinearCV {
            label: 'gain'
            volts: 3
            inVolts: inStream('gain')
        }
        ExponentialCV {
            label: 'decay'
            inVolts: inStream('decay')
            from: .0001
            logBase: 2
        }



}
