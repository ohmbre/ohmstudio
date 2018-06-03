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
			out: modules[9].jack("signal")
		},
		Cable {
			inp: modules[0].jack("L")
			out: modules[1].jack("signal")
		},
		Cable {
			out: modules[2].jack("signal")
			inp: modules[4].jack("in")
		},
		Cable {
			inp: modules[1].jack("v/oct")
			out: modules[4].jack("out")
		},
		Cable {
			out: modules[7].jack("out")
			inp: modules[9].jack("v/oct")
		},
		Cable {
			out: modules[3].jack("signal")
			inp: modules[7].jack("in")
		},
		Cable {
			out: modules[5].jack("signal")
			inp: modules[8].jack("in")
		},
		Cable {
			inp: modules[6].jack("in")
			out: modules[8].jack("out")
		},
		Cable {
			inp: modules[3].jack("v/oct")
			out: modules[6].jack("out1")
		}
	]
	modules: [
		OutAudioModule {
			savedControlVolts: []
			x: -32.47224574684992
			y: -119.3193856328752},
		SineOscModule {
			savedControlVolts: [
				-1.0480226463493736
			]
			x: 21.77543079358304
			y: -174.93942863195917},
		SineOscModule {
			savedControlVolts: [
				-4.433494405739998
			]
			x: 82.86592344653809
			y: -157.4712852202797},
		SineOscModule {
			savedControlVolts: [
				2.479953034593091
			]
			x: 93.40142146134144
			y: -15.167278516441002},
		VCAModule {
			savedControlVolts: [
				-4.75279161824331
			]
			x: 64.39760714587078
			y: -227.64550190565228},
		SineOscModule {
			savedControlVolts: [
				0.7919577286920259
			]
			x: 172.94483674037429
			y: -124.62709621153545},
		MultipleModule {
			savedControlVolts: []
			x: 73.5065202413964
			y: -105.27152269458873},
		VCAModule {
			savedControlVolts: [
				-4.427981467559745
			]
			x: 32.75881233097084
			y: -22.56084051241976},
		VCAModule {
			savedControlVolts: [
				0.5617462789369831
			]
			x: 129.30265736445836
			y: -85.25734590016634},
		SineOscModule {
			savedControlVolts: [
				-1.5386002116239048
			]
			x: 24.54361315379299
			y: -73.92154348317365}
	]
	name: "new patch"}