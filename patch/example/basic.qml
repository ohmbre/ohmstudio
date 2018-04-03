import ".."
import "../.."

Patch {
    id: basicPatch
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
            out: modules[0].outJacks[0]
            inp: modules[1].inJacks[0]
        }
    ]
}
