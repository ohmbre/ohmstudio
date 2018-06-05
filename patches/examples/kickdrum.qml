import ohm.module.audio 1.0
import ohm.module.osc 1.0
import ohm.patch 1.0
import ohm.cable 1.0
import ohm.module.vca 1.0
import ohm.module.sequencer 1.0
import ohm.module.envelope 1.0
import ohm.module.multiple 1.0
import ohm.module.clock 1.0
import ohm.module.mix 1.0

Patch {
	cables: [
		Cable {
			out: modules[5].jack("trig")
			inp: modules[6].jack("gate")
		},
		Cable {
			inp: modules[2].jack("in")
			out: modules[7].jack("out2")
		},
		Cable {
			out: modules[6].jack("envelope")
			inp: modules[7].jack("in")
		},
		Cable {
			out: modules[2].jack("out")
			inp: modules[8].jack("v/oct")
		},
		Cable {
			out: modules[8].jack("signal")
			inp: modules[9].jack("in1")
		},
		Cable {
			inp: modules[3].jack("in")
			out: modules[7].jack("out1")
		},
		Cable {
			inp: modules[3].jack("gain")
			out: modules[4].jack("signal")
		},
		Cable {
			out: modules[3].jack("out")
			inp: modules[9].jack("in2")
		},
		Cable {
			inp: modules[0].jack("L")
			out: modules[9].jack("out")
		}
	]
	modules: [
		OutAudioModule {
			savedControlVolts: []
			x: 97.95738840498052
			y: 85.50544588639059},
		SineOscModule {
			savedControlVolts: [
				0,
				0
			]
			x: 82.86592344653809
			y: -157.4712852202797},
		VCAModule {
			savedControlVolts: [
				-4.176161097520611
			]
			x: -6.273839895900437
			y: -69.06752704507107},
		VCAModule {
			savedControlVolts: [
				-5
			]
			x: 46.61448652682566
			y: 6.271072994804399},
		SineOscModule {
			savedControlVolts: [
				-3.494547708133493,
				5
			]
			x: 48.690852777453074
			y: 58.246107981239675},
		ClockModule {
			savedControlVolts: [
				-0.005168379543984969
			]
			x: -88.5
			y: 31.5},
		ADModule {
			savedControlVolts: [
				-5,
				0.6619053266936774,
				5,
				1.8855569323243326
			]
			x: -16
			y: 48},
		MultipleModule {
			savedControlVolts: []
			x: -19.999292165351562
			y: -15.098888876832461},
		SineOscModule {
			savedControlVolts: [
				-3.0715152057494293,
				-1.8016603608984165
			]
			x: 47.7496713102563
			y: -71.45721141750005},
		MixModule {
			savedControlVolts: []
			x: 100.5
			y: -44}
	]
	name: "new patch"}