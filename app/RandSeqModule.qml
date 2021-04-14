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
    
    OutJack {
        label: 'voct'
        calc: `bool was_hi = false;
               long state = 0, cnt = 0;
               double calc() {
                  bool hi = clock >= 3;
                  if (hi && !was_hi) {
                      state = (cnt == 0) ? round(seed * 6.25 + 63.5) : (91 * state) % 127;
                      cnt = (cnt + 1) % (long)(notes*1.55 + 16.5);
                  }
                  was_hi = hi;
                  return state / 126. * octaves;
               }`
    }
}
