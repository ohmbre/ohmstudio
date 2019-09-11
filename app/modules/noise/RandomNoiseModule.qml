import ohm 1.0

Module {
    objectName: 'RandomNoiseModule'
    label: 'Random Noise'

    outJacks: [
        OutJack {
            label: 'signal'
            stream: '@gain*random(1,-1v,1v,0)'
        }
    ]

    inJacks: [
        InJack { label: 'gain' }
    ]

    cvs: [
        LinearCV {
            label: 'gain'
            inVolts: inStream('gain')
        }
    ]


}
