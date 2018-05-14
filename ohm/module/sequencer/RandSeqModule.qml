import ohm.module 1.0
import ohm.jack.out 1.0
import ohm.jack.in 1.0
import ohm.cv 1.0

Module {
    objectName: 'RandSeqModule'
    label: 'Random Sequencer'

    outJacks: [
        OutJack {
	    label: 'v/oct'
	    stream: clockSeq(inStream('clock'),1,seededSample(scaleToVoct(cv('scale')),cv('notes'),cv('seed')))
	}
    ]

    inJacks: [
        InJack {label: 'clock'},
	InJack {label: 'seed'}
    ]

    cvs: [
	QuantCV {
	    streams: scales
	    label: 'scale'
	},
	LogScaleCV {
	    label: 'seed'
	    voltage: inStream('seed')
	    from: '666'
	},
	QuantCV {
	    label: 'notes'
	    streams: '[0,1,2,3,4,5,6,7,8,9]'
	},
	LogScaleCV {
	    label: 'test1'
	    control: 5
	},
	LogScaleCV {
	    label: 'test2'
	},
	LogScaleCV {
	    label: 'test3'
	}
	
	    
	
    ]
	
}
