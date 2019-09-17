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
        ExponentialCV {
            label: 'risedamp'
            inVolts: inStream('risedamp')
            from: '200ms'
            logBase: 1.5
        },
        ExponentialCV {
            label: 'falldamp'
            inVolts: inStream('falldamp')
            from: '200ms'
            logBase: 1.5
        }
    ]

}

