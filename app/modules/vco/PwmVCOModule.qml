import ohm 1.0

Module {
    objectName: 'PwmVCOModule'
    label: 'PWM VCO'

    outJacks: [
        OutJack {
            label: 'signal'
            stream: '@gain * pwm(@freq,@duty/20)'
        }
    ]

    inJacks: [
        InJack { label: 'v/oct' },
        InJack { label: 'duty' },
        InJack { label: 'gain' }
    ]

    cvs: [
        ExponentialCV {
            label: 'freq'
            inVolts: inStream('v/oct')
            from: '440hz'
        },
        LinearCV {
            label: 'duty'
            inVolts: inStream('duty')
            from: '10'
        },
        LinearCV {
            label: 'gain'
            controlVolts: 3
            inVolts: inStream('gain')
        }
    ]


}
