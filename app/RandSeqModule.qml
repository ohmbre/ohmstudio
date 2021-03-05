Module {
    label: 'Random Sequencer'

    InJack {label: 'clock'}

    CV {
        label: 'seed'
        translate: v => Math.floor(v*6.25+63.5)
        decimals: 0
    }    
    CV {
        label: 'notes'
        translate: v => Math.floor(v*1.55+16.5)
        decimals: 0
    }
    CV { label: 'octaves'; volts: 1 }

    Variable { label: 'gate' }
    Variable { label: 'count' }
    Variable { label: 'state' } 
    

    OutJack {
        label: 'voct'
        expression: 
            'state := (gate == 0) and (clock > 3) ? (count == 0 ? round(seed*6.25 + 63.5) : (91 * state) % 127) : state;
             count := (gate == 0) and (clock > 3) ? (count + 1) % floor(notes*1.55+16.5) : count;
             gate := clock > 3 ? 1 : 0;
             state / 126 * octaves'
    }

}
