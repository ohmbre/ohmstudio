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
		},
		Cable {
			inp: modules[4].jack("gain")
			out: modules[11].jack("out2")
		},
		Cable {
			out: modules[2].jack("envelope")
			inp: modules[11].jack("in")
		},
		Cable {
			inp: modules[9].jack("duty")
			out: modules[11].jack("out1")
		}
	]
	modules: [
		AudioModule {
			savedControlVolts: []
			x: 100.79792755962137
			y: -21.806807636688063},
		ClockModule {
			savedControlVolts: [
				4.906090446905534
			]
			x: 34.255669018901244
			y: 88.20984359126919},
		ADModule {
			savedControlVolts: [
				-0.3059479544887136,
				2.872670277747547,
				1.604843421866942,
				1.004467085206457,
				2.5012937938873296,
				-0.26665107705041713
			]
			x: -51.06369487419158
			y: 47.16262127397033},
		MultipleModule {
			savedControlVolts: []
			x: -6.0020296111529206
			y: 63.49647964674},
		SawOscModule {
			savedControlVolts: [
				-1.07154126776609,
				-1.2334669380067123
			]
			x: -53.969885800762995
			y: -25.893820225593686},
		RandSeqModule {
			savedControlVolts: [
				3.333333333333332,
				3.502469572717512,
				-5.625,
				0.006582612752545458
			]
			x: 53.73496186401519
			y: 50.738612830829766},
		MultipleModule {
			savedControlVolts: []
			x: 52.394466601750764
			y: 14.020492893709388},
		SlideModule {
			savedControlVolts: [
				-4.199343050247112,
				-1.7357004806099425
			]
			x: 5.011319447398478
			y: 23.998866468056576},
		MultipleModule {
			savedControlVolts: []
			x: 61.55398574737001
			y: -54.21446170624279},
		PwmOscModule {
			savedControlVolts: [
				-0.06707418255963304,
				-5.198873175889159,
				2.8350190534973905
			]
			x: 19.864729013003853
			y: -25.073903066930143},
		MixModule {
			savedControlVolts: []
			x: -0.4939313336650457
			y: -53.309563613373484},
		MultipleModule {
			savedControlVolts: []
			x: -47.68345944697023
			y: 11.640106399622823}
	]
	name: "new patch"}