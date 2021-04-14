Module {

    label: 'Noise VCO'
    InJack { label: 'inGain' }
    CV {
        label: 'ctrlGain'
        volts: 3
    }
    
    OutJack {
        label: 'noise'
        calc: `bool init = true;
               double calc() {
                   if (init) {
                      srand(666);
                      init = false;
                   }
                   return (ctrlGain + inGain) * (2. * rand() / RAND_MAX - 1);
               }`
    }
}
