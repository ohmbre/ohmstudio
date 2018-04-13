import ohm.patch 1.0
import ohm.module.clock 1.0
import ohm.module.sequencer 1.0
import ohm.module.cv 1.0
import ohm.module.envelope 1.0
import ohm.module.vca 1.0
import ohm.module.osc 1.0
import ohm.module.vca 1.0
import ohm.module.hw.audio 1.0
import ohm.cable 1.0

Patch {
    name: "example"

    modules: [
        ClockModule {x: -130; y: -65},
        SequencerModule {x: -80; y: -10},
        SlewLimitModule {x: -5; y: -75},
        ADSRModule {x: -40; y: 55},
        WavetableOscModule {x: 70; y: -25},
        VCAModule {x: 55; y:55},
        OutAudioHwModule {x: 110; y: 85}
    ]
    cables: [
        Cable {
            out: modules[0].jack("trig")
            inp: modules[1].jack("clock")
        }
    ]
}
