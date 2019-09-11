import ohm 1.0

Module {
    objectName: 'MixModule'
    label: 'Mix'

    outJacks: [
        OutJack {
            label: 'out'
            stream: '$ch1 + $ch2 + $ch3 + $ch4 + $ch5 + $ch6 + $ch7 + $ch8'
        }
    ]

    cvs: [
        LinearCV { label: 'ch1'; inVolts: inStream('ch1'); },
        LinearCV { label: 'ch1'; inVolts: inStream('ch1'); },
        LinearCV { label: 'ch1'; inVolts: inStream('ch1'); },
        LinearCV { label: 'ch1'; inVolts: inStream('ch1'); },
        LinearCV { label: 'ch1'; inVolts: inStream('ch1'); },
        LinearCV { label: 'ch1'; inVolts: inStream('ch1'); },
        LinearCV { label: 'ch1'; inVolts: inStream('ch1'); },
        LinearCV { label: 'ch1'; inVolts: inStream('ch1'); }
    ]

    inJacks: [
        InJack { label: 'ch1' },
        InJack { label: 'ch2' },
        InJack { label: 'ch3' },
        InJack { label: 'ch4' },
        InJack { label: 'ch5' },
        InJack { label: 'ch6' },
        InJack { label: 'ch7' },
        InJack { label: 'ch8' }
    ]

}
