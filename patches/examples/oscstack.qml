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
import ohm.module.cv 1.0

Patch {
	cables: [
		Cable {
			out: modules[1].jack("trig")
			inp: modules[3].jack("in")
		},
		Cable {
			inp: modules[2].jack("gate")
			out: modules[3].jack("out2")
		},
		Cable {
			out: modules[3].jack("out1")
			inp: modules[5].jack("clock")
		},
		Cable {
			out: modules[5].jack("v/oct")
			inp: modules[6].jack("in")
		},
		Cable {
			out: modules[6].jack("out1")
			inp: modules[7].jack("input")
		},
		Cable {
			inp: modules[4].jack("v/oct")
			out: modules[7].jack("output")
		},
		Cable {
			inp: modules[0].jack("outL")
			out: modules[8].jack("out2")
		},
		Cable {
			inp: modules[0].jack("outR")
			out: modules[8].jack("out1")
		},
		Cable {
			out: modules[2].jack("envelope")
			inp: modules[4].jack("gain")
		},
		Cable {
			out: modules[4].jack("signal")
			inp: modules[10].jack("in1")
		},
		Cable {
			out: modules[9].jack("signal")
			inp: modules[10].jack("in2")
		},
		Cable {
			inp: modules[8].jack("in")
			out: modules[10].jack("out")
		},
		Cable {
			out: modules[6].jack("out2")
			inp: modules[9].jack("v/oct")
		}
	]
	modules: [
		AudioModule {
			savedControlVolts: []
			x: 112.22353052363394
			y: -8.096084079873094},
		ClockModule {
			savedControlVolts: [
				5.7698265542401685
			]
			x: 34.255669018901244
			y: 88.20984359126919},
		ADModule {
			savedControlVolts: [
				-3.9719888506349807,
				1.5328322797428982,
				0,
				-0.0016456531881328118,
				2.9331618475546435,
				-2.44080222408022
			]
			x: -44.42533284489616
			y: 31.894388606590837},
		MultipleModule {
			savedControlVolts: []
			x: -6.0020296111529206
			y: 63.49647964674},
		SawOscModule {
			savedControlVolts: [
				-1.0028214320183153,
				1.9336317219125991
			]
			x: -25.735615587499638
			y: -10.394872562234355},
		RandSeqModule {
			savedControlVolts: [
				-5,
				-1.498472361869002,
				-0.625,
				0.006582612752545458
			]
			x: 57.73392290141976
			y: 39.31300986681708},
		MultipleModule {
			savedControlVolts: []
			x: 50.511904180991905
			y: -3.3947637840855123},
		SlideModule {
			savedControlVolts: [
				-3.230881536102679,
				-10
			]
			x: 9.721938979182141
			y: 25.454071096469534},
		MultipleModule {
			savedControlVolts: []
			x: 96.33413994147872
			y: -70.41885172849788},
		PwmOscModule {
			savedControlVolts: [
				-0.0016456531881328118,
				-3.1638073535430378,
				1.4690494035595254
			]
			x: 43.76283231846753
			y: -39.67829953138016},
		MixModule {
			savedControlVolts: []
			x: -0.4939313336650457
			y: -53.309563613373484}
	]
	name: "new patch"}