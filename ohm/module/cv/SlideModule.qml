import ohm.module 1.0
import ohm.jack.out 1.0
import ohm.jack.in 1.0
import ohm.cv 1.0

Module {
    objectName: 'SlideModule'

    label: 'Slide'

    outJacks: [
        OutJack {
	    label: 'output'
	    stream: 'slew($input,@lag,@shape)'
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
	    from: '5ms'
	},
	LinearCV {
	    label: 'shape'
	    inVolts: inStream('shape')
	    from: '-1.5'
	}
    ]
	
}

