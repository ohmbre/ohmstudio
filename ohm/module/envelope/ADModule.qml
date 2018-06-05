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
		var sincetrig = 't-triggered($gate)';
		var attackcurve = '((%1) / @attack) ^ @atkshape'.arg(sincetrig);
		var decaycurve = '(1 - (((%1)-@attack) / @decay)) ^ @decshape'.arg(sincetrig);
		return '10v * (smaller(%1, @attack) ? (%2) : (smaller(%1, @attack + @decay) ? (%3) : 0))'
		    .arg(sincetrig).arg(attackcurve).arg(decaycurve)
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
	LinearCV {
	    label: 'atkshape'
	    inVolts: inStream('atkshape')
	    from: '1'
	},
	LinearCV {
	    label: 'decshape'
	    inVolts: inStream('decshape')
	    from: '1'
	}	
    ]
}
