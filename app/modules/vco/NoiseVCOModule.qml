import ohm 1.0

Module {
    objectName: 'NoiseVCOModule'
    label: 'Noise VCO'

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
            controlVolts: 3
            inVolts: inStream('gain')
        }
    ]


}
