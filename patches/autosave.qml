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
		OutAudioModule {
			x: -27.486137900018775
			y: 77.5799299717504
		},
		SawOscModule {
			x: 8.851677703983569
			y: -7.763613396037272
		},
		VCAModule {
			x: -0.5
			y: 39
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
			inp: modules[2].jack("gain")
			out: modules[3].jack("envelope")
		},
		Cable {
			out: modules[4].jack("trig")
			inp: modules[6].jack("in")
		},
		Cable {
			inp: modules[3].jack("gate")
			out: modules[6].jack("out2")
		},
		Cable {
			out: modules[1].jack("signal")
			inp: modules[2].jack("in")
		},
		Cable {
			inp: modules[0].jack("signal")
			out: modules[2].jack("out")
		},
		Cable {
			inp: modules[8].jack("v/oct")
			out: modules[10].jack("v/oct")
		},
		Cable {
			out: modules[7].jack("trig")
			inp: modules[10].jack("clock")
		},
		Cable {
			inp: modules[1].jack("v/oct")
			out: modules[5].jack("v/oct")
		},
		Cable {
			inp: modules[5].jack("clock")
			out: modules[6].jack("out1")
		}
	]
}