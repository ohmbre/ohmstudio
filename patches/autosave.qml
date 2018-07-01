import ohm 1.0
import modules 1.0

Patch {
    cables: [
        Cable {
            out: modules[0].jack("signal")
            inp: modules[1].jack("outL")
        }
    ]
    modules: [
        SineOscModule {
            savedControlVolts: [
                0.9913150992763438,
                -4.095956852800531
            ]
            x: 0
            y: 0
        }
,
        AudioCodecModule {
            savedControlVolts: []
            x: 48.25
            y: -40.75
        }

    ]
    name: "new patch"
}
