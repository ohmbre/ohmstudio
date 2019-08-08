import ohm 1.0

Module {
    objectName: 'SlideModule'

    label: 'Slide'

    outJacks: [
        OutJack {
            label: 'output'
            stream: 'slew($input,@risedamp,@falldamp)'
        }
    ]

    inJacks: [
        InJack {label: 'input'},
        InJack {label: 'risedamp'},
        InJack {label: 'falldamp'}
    ]

    cvs: [
        LogScaleCV {
            label: 'risedamp'
            inVolts: inStream('risedamp')
            from: '0.2'
            logBase: 1.2
        },
        LogScaleCV {
            label: 'falldamp'
            inVolts: inStream('falldamp')
            from: '0.2'
            logBase: 1.2
        }
    ]

}

