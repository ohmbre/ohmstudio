import ohm.patch 1.0
import ohm.module.clock 1.0
import ohm.module.sequencer 1.0
import ohm.module.cv 1.0
import ohm.module.envelope 1.0
import ohm.module.vca 1.0
import ohm.module.osc 1.0
import ohm.module.audio 1.0
import ohm.cable 1.0
import ohm.module.multiple 1.0

Patch {
	name: "example"
	modules: [
		SawOscModule {
			x: 9.15271317227689
			y: 8.943855094243077
		},
		VCAModule {
			x: -9.194162403008704
			y: 44.89961020204112
		},
		ADSRModule {
			x: -60.5
			y: 43.5
		},
		ClockModule {
			x: -108.08724349291924
			y: -67.78021384291617
		},
		RandSeqModule {
			x: -38.5
			y: -47
		},
		MultipleModule {
			x: -101
			y: -5
		},
		ClockModule {
			x: 14.996060877474179
			y: -80.41907276051472
		},
		SineOscModule {
			x: 69.70122504570736
			y: 17.12423692874802
		},
		OutAudioModule {
			x: 45.34033162704077
			y: 72.68460237660838
		},
		RandSeqModule {
			x: 74.40245009141483
			y: -54.726159049356625
		}
	]
	cables: [
		Cable {
			inp: modules[1].jack("gain")
			out: modules[2].jack("envelope")
		},
		Cable {
			out: modules[3].jack("trig")
			inp: modules[5].jack("in")
		},
		Cable {
			inp: modules[2].jack("gate")
			out: modules[5].jack("out2")
		},
		Cable {
			out: modules[0].jack("signal")
			inp: modules[1].jack("in")
		},
		Cable {
			inp: modules[7].jack("v/oct")
			out: modules[9].jack("v/oct")
		},
		Cable {
			out: modules[6].jack("trig")
			inp: modules[9].jack("clock")
		},
		Cable {
			inp: modules[0].jack("v/oct")
			out: modules[4].jack("v/oct")
		},
		Cable {
			inp: modules[4].jack("clock")
			out: modules[5].jack("out1")
		},
		Cable {
			out: modules[1].jack("out")
			inp: modules[8].jack("signal")
		}
	]
}