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
            x: -90
            y: -10.5
        }
,
        AudioCodecModule {
            savedControlVolts: []
            x: 0
            y: 0
        }

    ]
    name: ""
}
