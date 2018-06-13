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
			inp: modules[4].jack("in1")
			out: modules[11].jack("signal")
		},
		Cable {
			inp: modules[0].jack("L")
			out: modules[4].jack("out")
		},
		Cable {
			out: modules[1].jack("trig")
			inp: modules[5].jack("in")
		},
		Cable {
			inp: modules[2].jack("gate")
			out: modules[5].jack("out2")
		},
		Cable {
			out: modules[5].jack("out1")
			inp: modules[7].jack("clock")
		},
		Cable {
			inp: modules[4].jack("in2")
			out: modules[6].jack("signal")
		},
		Cable {
			out: modules[2].jack("envelope")
			inp: modules[9].jack("gain")
		},
		Cable {
			out: modules[3].jack("out2")
			inp: modules[6].jack("gain")
		},
		Cable {
			out: modules[3].jack("out1")
			inp: modules[11].jack("gain")
		},
		Cable {
			inp: modules[3].jack("in")
			out: modules[9].jack("out")
		},
		Cable {
			out: modules[7].jack("v/oct")
			inp: modules[8].jack("in")
		},
		Cable {
			out: modules[8].jack("out2")
			inp: modules[11].jack("v/oct")
		},
		Cable {
			out: modules[8].jack("out1")
			inp: modules[10].jack("input")
		},
		Cable {
			inp: modules[6].jack("v/oct")
			out: modules[10].jack("output")
		}
	]
	modules: [
		AudioModule {
			savedControlVolts: []
			x: -41.08075893921432
			y: -30.363396033055892},
		ClockModule {
			savedControlVolts: [
				1.483760882714268
			]
			x: 43.255669018901244
			y: 79.70984359126919},
		ADModule {
			savedControlVolts: [
				-0.20039972108484871,
				0.7173447428428217,
				1.018355737767128,
				0.8351359756192238
			]
			x: -60.07330910469386
			y: 40.47553687809295},
		MultipleModule {
			savedControlVolts: []
			x: -90.06199578644942
			y: -28.39426556623789},
		MixModule {
			savedControlVolts: []
			x: 0.5296287452066508
			y: -24.823302699978626},
		MultipleModule {
			savedControlVolts: []
			x: -6.0020296111529206
			y: 63.49647964674},
		SawOscModule {
			savedControlVolts: [
				-1.0011757788301825,
				-0.6150878158152215
			]
			x: -31.337953243014226
			y: 6.7856295813437555},
		RandSeqModule {
			savedControlVolts: [
				-5,
				2.6992250351899756,
				5
			]
			x: 57.73392290141976
			y: 39.31300986681708},
		MultipleModule {
			savedControlVolts: []
			x: 50.511904180991905
			y: -9.828380658903939},
		VCAModule {
			savedControlVolts: [
				0.930810289894275,
				-5
			]
			x: -83.12201324018997
			y: 5.134221472779927},
		SlideModule {
			savedControlVolts: [
				-5,
				1.1189670116065873
			]
			x: 9.721938979182141
			y: 25.454071096469534},
		PwmOscModule {
			savedControlVolts: [
				-1.6007292888965985,
				-2.7548790449711404,
				5
			]
			x: -20.438126196295116
			y: -68.89960956065397}
	]
	name: "new patch"}
