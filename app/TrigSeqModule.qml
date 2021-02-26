Module {

    label: 'Trig Sequencer'

    InJack {label: 'clock'}
    InJack {label: 'reset'}

    BinaryCV { label: '1' }
    BinaryCV { label: '2' }
    BinaryCV { label: '3' }
    BinaryCV { label: '4' }
    BinaryCV { label: '5' }
    BinaryCV { label: '6' }
    BinaryCV { label: '7' }
    BinaryCV { label: '8' }
    BinaryCV { label: '9' }
    BinaryCV { label: '10' }
    BinaryCV { label: '11' }
    BinaryCV { label: '12' }
    BinaryCV { label: '13' }
    BinaryCV { label: '14' }
    BinaryCV { label: '15' }
    BinaryCV { label: '16' }
    BinaryCV { label: '17' }
    BinaryCV { label: '18' }
    BinaryCV { label: '19' }
    BinaryCV { label: '20' }
    BinaryCV { label: '21' }
    BinaryCV { label: '22' }
    BinaryCV { label: '23' }
    BinaryCV { label: '24' }
    BinaryCV { label: '25' }
    BinaryCV { label: '26' }
    BinaryCV { label: '27' }
    BinaryCV { label: '28' }
    BinaryCV { label: '29' }
    BinaryCV { label: '30' }
    BinaryCV { label: '31' }
    BinaryCV { label: '32' }
    BinaryCV {
        label: 'reset'
    }

    Variable { label: 'gate' }
    Variable { label: 'count' }
    Variable {
        label: 'values';
        value: mapList(cvs, cv => cv.volts)
    }

    OutJack {
        label: 'trig'
        expression:
            'count := reset > 3 ? 0 : ((gate == 0) and (clock > 3) ? ((count + 1) % 32) : count);
             gate := (clock > 3) ? 1 : 0;
             gate == 0 ? 0 : values[count]'
    }

}
