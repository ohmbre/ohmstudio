Module {

    label: 'Sample Hold'
    InJack {label: 'signal'}
    InJack {label: 'trig'}
    
        
    OutJack {
        label: 'out'
        calc: `double state = 0;
               bool was_hi = false;
               double calc() {
                   bool hi = trig >= 3;
                   if (hi && !was_hi) 
                       state = signal;
                   was_hi = hi;
                   return state;
               }`
    }

}
