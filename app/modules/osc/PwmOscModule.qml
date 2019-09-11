import ohm 1.0

Module {
    objectName: 'PwmOscModule'
    label: 'PWM Osc'

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
        LogScaleCV {
            label: 'freq'
            inVolts: inStream('v/oct')
            from: '220hz'
        },
        LinearCV {
            label: 'duty'
            inVolts: inStream('duty')
            from: '10'
        },
        LinearCV {
            label: 'gain'
            inVolts: inStream('gain')
        }
    ]


}
