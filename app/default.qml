Patch {
    modules: [
    AudioOutModule {
        objectName: "AudioOutModule"
        x: 40
        y: 30
        devId: "alsa|2ch|default"
    },

    SineVCOModule {
        objectName: "SineVCOModule"
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
