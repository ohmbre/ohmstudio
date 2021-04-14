Module {

    label: 'Mix'

    InJack { label: 'ch1' }
    InJack { label: 'ch2' }
    InJack { label: 'ch3' }
    InJack { label: 'ch4' }
    InJack { label: 'ch5' }
    InJack { label: 'ch6' }
    InJack { label: 'ch7' }
    InJack { label: 'ch8' }
    
    property var todb: logistic(-48,24,0,0.2)
    
    CV { label: 'dB1'; translate: todb; unit: 'dB'}
    CV { label: 'dB2'; translate: todb; unit: 'dB'}
    CV { label: 'dB3'; translate: todb; unit: 'dB'}
    CV { label: 'dB4'; translate: todb; unit: 'dB'}
    CV { label: 'dB5'; translate: todb; unit: 'dB'}
    CV { label: 'dB6'; translate: todb; unit: 'dB'}
    CV { label: 'dB7'; translate: todb; unit: 'dB'}
    CV { label: 'dB8'; translate: todb; unit: 'dB'}

    OutJack {
        label: 'mix'
        calc: `double todB(double vgain) {
                   return -48. + 72.*pow(48./72, exp(-0.2*vgain));
               }

               double amplify(double v, double vgain) {
                   return v * pow(10, todB(vgain)/20.0);
               }

               double calc() {
                   return amplify(ch1,dB1) + amplify(ch2,dB2) + 
                          amplify(ch3,dB3) + amplify(ch4,dB4) + 
                          amplify(ch5,dB5) + amplify(ch6,dB6) +
                          amplify(ch7,dB7) + amplify(ch8,dB8);
               }`
    }

}
