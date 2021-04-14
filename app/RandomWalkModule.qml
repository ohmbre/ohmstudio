Module {

    label: 'Random Walk'

    InJack { label: 'inStep' }
    CV {
        label: 'ctrlStep'
        translate: v => .01 * 1.7**v
        decimals: 4
    }
    
    InJack { label: 'inLowBound' }
    CV {
        label: 'ctrlLowBound' 
        volts: -10
    }
    
    InJack { label: 'inHiBound' }
    CV { 
        label: 'ctrlHiBound' 
        volts: 10
    }
    

    OutJack {
        label: 'out'
        calc: `bool init = false;
               double position = 0;
               double calc() {
                   if (!init) {
                       srand(666);
                       init = true;
                   }
                   position += ((rand() % 2) ? -1 : 1) * (.01 * pow(1.7, ctrlStep + inStep));
                   double lowBound = inLowBound+ctrlLowBound;
                   double hiBound = inHiBound+ctrlHiBound;
                   position = clamp(position, lowBound, hiBound);
                   return position;
               }`
    }
}
