import ohm 1.0
import modules 1.0

Patch {
    cables: [
        Cable {
            out: modules[2].jack("out")
            inp: modules[3].jack("in")
        },
        Cable {
            out: modules[1].jack("out")
            inp: modules[2].jack("in2")
        },
        Cable {
            inp: modules[0].jack("outR")
            out: modules[3].jack("out4")
        },
        Cable {
            inp: modules[0].jack("outL")
            out: modules[3].jack("out1")
        },
        Cable {
            out: modules[0].jack("inR")
            inp: modules[1].jack("in")
        },
        Cable {
            out: modules[0].jack("inL")
            inp: modules[4].jack("in")
        },
        Cable {
            inp: modules[2].jack("in1")
            out: modules[4].jack("out")
        }
    ]
    modules: [
        AudioCodecModule {
            savedControlVolts: []
            x: -37.894228715640224
            y: 75.65760434084518
        }
,
        VCAModule {
            savedControlVolts: [
                5.102983592297823,
                0
            ]
            x: 38.436258801241934
            y: 17.21695488518924
        }
,
        MixModule {
            savedControlVolts: []
            x: 110.23047910658977
            y: 68.34794454969301
        }
,
        MultipleModule {
            savedControlVolts: []
            x: 183.65076609506173
            y: 78.5128120189031
        }
,
        VCAModule {
            savedControlVolts: [
                4.073516017570851,
                0
            ]
            x: 36.76172795205184
            y: 78.33428456045408
        }

    ]
    name: ""
}
