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
            from: 'notehz(C,4)'
        },
        LinearCV {
            label: 'duty'
            inVolts: inStream('duty')
            from: '10'
        },
        LogScaleCV {
            label: 'gain'
            inVolts: inStream('gain')
            from: 2
            logBase: 1.38
        }
    ]


}
