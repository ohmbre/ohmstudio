import ohm.module.audio 1.0
import ohm.module.osc 1.0
import ohm.patch 1.0
import ohm.cable 1.0
import ohm.module.vca 1.0
import ohm.module.sequencer 1.0
import ohm.module.envelope 1.0
import ohm.module.multiple 1.0
import ohm.module.clock 1.0

Patch {
	cables: [
		Cable {
			inp: modules[0].jack("R")
			out: modules[3].jack("trig")
		}
	]
	modules: [
		OutAudioModule {
			savedControlVolts: []
			x: -28
			y: -68},
		SineOscModule {
			savedControlVolts: [
				6.742167087561871,
				3
			]
			x: 66.48773550952637
			y: -98.29397622076135},
		SineOscModule {
			savedControlVolts: [
				-1.2851252688297343,
				3
			]
			x: -89.95876293736876
			y: -98.47793200139938},
		ClockModule {
			savedControlVolts: [
				0
			]
			x: 0
			y: -5}
	]
	name: "new patch"}