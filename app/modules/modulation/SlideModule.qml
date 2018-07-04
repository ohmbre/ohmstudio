import ohm 1.0

Module {
    objectName: 'SlideModule'

    label: 'Slide'

    outJacks: [
        OutJack {
            label: 'output'
            stream: 'slew($input,@lag,@shape/7)'
        }
    ]

    inJacks: [
        InJack {label: 'input'},
        InJack {label: 'lag'},
        InJack {label: 'shape'}
    ]

    cvs: [
        LogScaleCV {
            label: 'lag'
            inVolts: inStream('lag')
            from: '2ms'
        },
        LinearCV {
            label: 'shape'
            inVolts: inStream('shape')
            from: '-1'
        }
    ]

}

