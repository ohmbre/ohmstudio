Module {
    label: 'Flip Flop'
    InJack {label: 'trig'}

    OutJack {
        label: 'out'
        calc: `bool was_hi = false;
               double state = 0;
               double calc() {
                   bool hi = (trig > 3) ? 1 : 0;
                   state = (hi && !was_hi) ? (10 - state) : state;
                   was_hi = hi;
                   return state;
               }`
    }
}
