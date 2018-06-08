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
			inp: modules[6].jack("v/oct")
			out: modules[8].jack("out1")
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
			inp: modules[10].jack("input")
		},
		Cable {
			out: modules[10].jack("output")
			inp: modules[11].jack("v/oct")
		}
	]
	modules: [
		OutAudioModule {
			savedControlVolts: []
			x: -37.77983187013092
			y: -25.962159940944957},
		ClockModule {
			savedControlVolts: [
				1.485406535902401
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
			x: 12.082873486997869
			y: -22.072530142409278},
		MultipleModule {
			savedControlVolts: []
			x: -6.0020296111529206
			y: 63.49647964674},
		SawOscModule {
			savedControlVolts: [
				-1.0011757788301825,
				-0.6150878158152215
			]
			x: -12.082545340028446
			y: 16.13825627707979},
		RandSeqModule {
			savedControlVolts: [
				4.166666666666666,
				2.6992250351899756,
				5
			]
			x: 41.229287556003555
			y: 37.6625463322755},
		MultipleModule {
			savedControlVolts: []
			x: 54.362985761589016
			y: -0.47575396316801744},
		VCAModule {
			savedControlVolts: [
				0.930810289894275,
				-5
			]
			x: -83.12201324018997
			y: 5.134221472779927},
		SlideModule {
			savedControlVolts: [
				-4.27053136577709,
				-2.614970893693388
			]
			x: 53.76838206035973
			y: -38.44337727929724},
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