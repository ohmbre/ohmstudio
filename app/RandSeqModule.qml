import ohm 1.0

Module {
    label: 'Random Sequencer'

    InJack {label: 'trig'}

    CV {
        label: 'numnotes'
        translate: v => Math.floor(1 + (v+10)/20 * 31.999999)
        decimals: 0
    }

    CV { label: 'vmin'; volts: 0 }
    CV { label: 'vmax'; volts: 1 }
    CV { label: 'seed' }

    OutJack {
        label: 'voct'
        stateVars: ({count: 0, state: 1, sample: 0, gate: 0})
        expression: 'if ((gate == 0) and (trig > 3))
                     {
                       state := (count == 0) ? round(6666 + 100*seed) : state;
                       sample := state / 2147483647 * (vmax - vmin) + vmin;
                       state := (48271 * state) % 2147483647;
                       count := (count + 1) % floor(1 + (numnotes+10)/20 * 31.999999)
                     };
                     gate := (trig > 3) ? 1 : 0;
                     sample'
    }

}
