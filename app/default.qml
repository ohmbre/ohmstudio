Patch {
    modules: [
    AudioOutModule {
        x: 40
        y: 30
    },

    SineVCOModule {
        x: -15
        y: -35
        CV {
        label: "ctrlFreq"
        volts: 0
        }
        CV {
        label: "ctrlGain"
        volts: 3
        }
    }
    ]
    Cable {
    inp: modules[0].jack('0')
    out: modules[1].jack('sinusoid')
    }
}
