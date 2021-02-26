Module {
    label: 'Random Sequencer'

    InJack {label: 'trig'}

    CV {
        label: 'numnotes'
        translate: v => Math.floor(1 + (v+10)/20 * 31.999999)
        decimals: 0
    }
    CV {
        label: 'seed'
        translate: v => Math.round(11+v)
        decimals: 0
    }
    CV { label: 'vmin'; volts: 0 }
    CV { label: 'vmax'; volts: 1 }

    Variable { label: 'count' }
    Variable { label: 'state'; value: 6 }
    Variable { label: 'sample'; value: 0 }
    Variable { label: 'gate' }

    OutJack {
        label: 'voct'
        expression: 'if ((gate == 0) and (trig > 3))
                     {
                       state := (count == 0) ? round(11 + seed) : state;
                       sample := state / 2147483647 * (vmax - vmin) + vmin;
                       state := (48271 * state) % 2147483647;
                       count := (count + 1) % floor(1 + (numnotes+10)/20 * 31.999999)
                     };
                     gate := trig > 3 ? 1 : 0;
                     sample'
    }

}
