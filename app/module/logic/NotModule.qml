import ohm.module 1.0                                                                              
import ohm.jack.in 1.0                                                                             
import ohm.jack.out 1.0                                                                            
import ohm.cv 1.0

Module {
    objectName: 'NotModule'

    label: 'Not'

    outJacks: [
	OutJack {
	    label: 'out'
	    stream: '($in >= 3) ? 0 : 10v'
	}
    ]

    inJacks: [
	InJack {label: 'in'}
    ]
}
