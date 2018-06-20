import ohm.module 1.0                                                                              
import ohm.jack.in 1.0                                                                             
import ohm.jack.out 1.0                                                                            
import ohm.cv 1.0

Module {
    objectName: 'FlipFlopModule'

    label: 'Flip Flop'

    outJacks: [
	OutJack {
	    label: 'out'
	    stream: 'sequence($trig,[0v,10v])'
	}
    ]

    inJacks: [
	InJack {label: 'trig'}
    ]
}
