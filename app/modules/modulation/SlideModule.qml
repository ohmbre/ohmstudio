import ohm 1.0

Module {
    objectName: 'SlideModule'

    label: 'Slide'

    outJacks: [
        OutJack {
            label: 'output'
            stream: 'slew($input,@lag)'
        }
    ]

    inJacks: [
        InJack {label: 'input'},
        InJack {label: 'lag'}
    ]

    cvs: [
        LogScaleCV {
            label: 'lag'
            inVolts: inStream('lag')
            from: '0.2'
            logBase: 1.2
        }
    ]

}

