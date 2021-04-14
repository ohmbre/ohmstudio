Module {
    label: 'Distortion'
    tags: ['fx']

    InJack { label: 'input' }
    InJack { label: 'inHarsh' }
    CV {
        label: 'ctrlHarsh'
        translate: v=>v
    }
    OutJack {
        label: 'distorted'
        calc: `double calc() {
                   return 20 / (1 + exp(-input * pow(2., ctrlHarsh + inHarsh))) - 10;
               }`
    }
}
