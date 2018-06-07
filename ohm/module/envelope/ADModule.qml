import ohm.module 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0
import ohm.cv 1.0

Module {
    objectName: 'ADModule'

    label: 'A/D Envelope'

    outJacks: [
        OutJack {
	    label: 'envelope'
	    stream: {
		var sincetrig = '(t-triggered($gate))';
		var attackcurve = '((%1 / @attack) ^ @atkshape)'.arg(sincetrig);
		var decaycurve = '((1 - ((%1-@attack) / @decay)) ^ @decshape)'.arg(sincetrig);
		var atkcond = '(smaller(%1, @attack))'.arg(sincetrig)
		var deccond = '(smaller(%1, @attack + @decay))'.arg(sincetrig)
		return '10v * (%1 ? %2 : (%3 ? %4 : 0))'.arg(atkcond).arg(attackcurve).arg(deccond).arg(decaycurve)
	    }
	}
	
    ]

    inJacks: [
        InJack {label: 'gate'},
	InJack {label: 'attack'},
	InJack {label: 'decay'},
	InJack {label: 'atkshape'},
	InJack {label: 'decshape'}
    ]

    cvs: [
	LogScaleCV {
	    label: 'attack'
	    inVolts: inStream('attack')
	    from: '100ms'
	},
	LogScaleCV {
	    label: 'decay'
	    inVolts: inStream('decay')
	    from: '300ms'
	},
	LogScaleCV {
	    label: 'atkshape'
	    logBase: 4
	    inVolts: inStream('atkshape')
	    from: 1
	},
	LogScaleCV {
	    label: 'decshape'
	    logBase: '4'
	    inVolts: inStream('decshape')
	    from: 1
	}	
    ]
}
