import ohm.cable 1.0
import ohm.patch 1.0
import ohm.module.audio 1.0
import ohm.module.osc 1.0

Patch {
	cables: [
		Cable {
			inp: modules[0].jack("R")
			out: modules[1].jack("signal")
		},
		Cable {
			inp: modules[0].jack("L")
			out: modules[2].jack("signal")
		}
	]
	modules: [
		OutAudioModule {
			savedControlVolts: []
			x: -3.5
			y: 3.5},
		SineOscModule {
			savedControlVolts: [
				0,
				-2.3060052449363995
			]
			x: 44
			y: -77},
		SineOscModule {
			savedControlVolts: [
				0,
				-2.6373886065785697
			]
			x: -79
			y: -63}
	]
	name: "new patch"}