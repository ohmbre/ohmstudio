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
        expression: '20 / (1 + exp(-input * 2^ctrlHarsh)) - 10'
    }
}
