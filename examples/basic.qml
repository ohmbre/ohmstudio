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
        ClockModule {coords: "-130,-65"},
        SequencerModule {coords: "-80,-10"},
        SlewLimitModule {coords: "-5,-75"},
        ADSRModule {coords: "-40,55"},
        WavetableOscModule {coords: "70,-25"},
        VCAModule {coords: "55,55"},
        OutAudioHwModule {coords: "110,85"}
    ]
    cables: [
        Cable {
            out: modules[0].jack("trig")
            inp: modules[1].jack("clock")
        }
    ]
}
