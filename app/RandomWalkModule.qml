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
    
    Variable { label: 'randstate'; value: 666 }
    Variable { label: 'position'; value: 0 }
    OutJack {
        label: 'out'
        expression:
            'randstate := (48271 * randstate) % 2147483647;
             position += (randstate > 1073741823 ? 1 : -1)*(.01*1.7^(ctrlStep+inStep));
             position := position < (inLowBound+ctrlLowBound) ? (inLowBound+ctrlLowBound) : position;
             position := position > (inHiBound+ctrlHiBound) ? (inHiBound+ctrlHiBound) : position;
             position'
    }
}
