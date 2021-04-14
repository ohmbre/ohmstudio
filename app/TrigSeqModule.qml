Module {

    label: 'Trig Sequencer'

    InJack {label: 'clock'}
    InJack {label: 'reset'}

    BinaryCV { label: 't01' }
    BinaryCV { label: 't02' }
    BinaryCV { label: 't03' }
    BinaryCV { label: 't04' }
    BinaryCV { label: 't05' }
    BinaryCV { label: 't06' }
    BinaryCV { label: 't07' }
    BinaryCV { label: 't08' }
    BinaryCV { label: 't09' }
    BinaryCV { label: 't10' }
    BinaryCV { label: 't11' }
    BinaryCV { label: 't12' }
    BinaryCV { label: 't13' }
    BinaryCV { label: 't14' }
    BinaryCV { label: 't15' }
    BinaryCV { label: 't16' }
    BinaryCV { label: 't17' }
    BinaryCV { label: 't18' }
    BinaryCV { label: 't19' }
    BinaryCV { label: 't20' }
    BinaryCV { label: 't21' }
    BinaryCV { label: 't22' }
    BinaryCV { label: 't23' }
    BinaryCV { label: 't24' }
    BinaryCV { label: 't25' }
    BinaryCV { label: 't26' }
    BinaryCV { label: 't27' }
    BinaryCV { label: 't28' }
    BinaryCV { label: 't29' }
    BinaryCV { label: 't30' }
    BinaryCV { label: 't31' }
    BinaryCV { label: 't32' }
    BinaryCV { label: 'reset' }

    Variable {
        label: 'values';
        value: mapList(cvs, cv => cv.volts)
    }

    OutJack {
        label: 'trig'
        calc: `int cnt = 0;
               bool was_hi = false;
               double t = DBL_MAX;
               double calc() {
                   if (reset > 3) cnt = 0;
                   bool hi = clock > 3;
                   if (hi && !was_hi) {
                       cnt = (cnt + 1) % 32;
                       if (values[cnt] > 3) 
                           t = 0;
                   }
                   was_hi = hi;                  
                   return (t++ < 5*ms) ? 10 : 0;
               }`
        
    }

}
