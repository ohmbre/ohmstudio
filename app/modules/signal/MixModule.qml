import ohm 1.0

Module {

    label: 'Mix'


        OutJack {
            label: 'out'
            stream: '$ch1 + $ch2 + $ch3 + $ch4 + $ch5 + $ch6 + $ch7 + $ch8'
        }

        LinearCV { label: 'ch1'; inVolts: inStream('ch1') }
        LinearCV { label: 'ch2'; inVolts: inStream('ch2') }
        LinearCV { label: 'ch3'; inVolts: inStream('ch3') }
        LinearCV { label: 'ch4'; inVolts: inStream('ch4') }
        LinearCV { label: 'ch5'; inVolts: inStream('ch5') }
        LinearCV { label: 'ch6'; inVolts: inStream('ch6') }
        LinearCV { label: 'ch7'; inVolts: inStream('ch7') }
        LinearCV { label: 'ch8'; inVolts: inStream('ch8') }



        InJack { label: 'ch1' }
        InJack { label: 'ch2' }
        InJack { label: 'ch3' }
        InJack { label: 'ch4' }
        InJack { label: 'ch5' }
        InJack { label: 'ch6' }
        InJack { label: 'ch7' }
        InJack { label: 'ch8' }


}
