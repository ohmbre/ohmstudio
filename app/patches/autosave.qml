import ohm 1.0
import modules 1.0

Patch {
    cables: [
        Cable {
            out: modules[0].jack("signal")
            inp: modules[1].jack("outR")
        }
    ]
    modules: [
        SineOscModule {
            savedControlVolts: [
                -0.07448569444468056,
                2.495575346116766
            ]
            x: 5
            y: 6
        }
,
        AudioCodecModule {
            savedControlVolts: []
            x: 90.75
            y: -25.25
        }

    ]
    name: ""
}

