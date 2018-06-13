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
			out: modules[7].jack("v/oct")
			inp: modules[8].jack("in")
		},
		Cable {
			out: modules[8].jack("out1")
			inp: modules[9].jack("input")
		},
		Cable {
			out: modules[2].jack("envelope")
			inp: modules[3].jack("in")
		},
		Cable {
			out: modules[3].jack("out2")
			inp: modules[10].jack("gain")
		},
		Cable {
			out: modules[9].jack("output")
			inp: modules[10].jack("v/oct")
		},
		Cable {
			inp: modules[4].jack("in2")
			out: modules[10].jack("signal")
		},
		Cable {
			inp: modules[0].jack("L")
			out: modules[4].jack("out")
		},
		Cable {
			out: modules[8].jack("out2")
			inp: modules[11].jack("v/oct")
		},
		Cable {
			out: modules[3].jack("out1")
			inp: modules[11].jack("gain")
		},
		Cable {
			inp: modules[4].jack("in1")
			out: modules[11].jack("signal")
		}
	]
	modules: [
		AudioModule {
			savedControlVolts: []
			x: -100.45673417163653
			y: -51.23393042887312},
		ClockModule {
			savedControlVolts: [
				5.707689331244936
			]
			x: -67.06195581355996
			y: 1.189651798752152},
		ADModule {
			savedControlVolts: [
				0.24381073149348786,
				4.773587734974392,
				2.5193959789568154,
				2.2739395942751983,
				4.104491562566135,
				-0.02777730512134724
			]
			x: 21.17175931849465
			y: -9.617201734419382},
		MultipleModule {
			savedControlVolts: []
			x: 23.06805828593417
			y: -101.92339078527664},
		MixModule {
			savedControlVolts: []
			x: -60.98783461520543
			y: -115.3190222687926},
		MultipleModule {
			savedControlVolts: []
			x: -13.789156069914839
			y: 51.16686275370034},
		SawOscModule {
			savedControlVolts: [
				-2.228060104084358,
				-4.300777150680637
			]
			x: 69.85112475235474
			y: -132.74984352459643},
		RandSeqModule {
			savedControlVolts: [
				6.666666666666668,
				-5.3330215410084385,
				-0.625,
				0.0032913063762745054
			]
			x: 96.02062799033297
			y: 3.622013597491332},
		MultipleModule {
			savedControlVolts: []
			x: 112.37699636260731
			y: -44.902401646554154},
		SlideModule {
			savedControlVolts: [
				-4.13556017406374,
				1.300541120566363
			]
			x: 95.31124208529423
			y: -99.66390352623921},
		PwmOscModule {
			savedControlVolts: [
				-2.201928452151149,
				-3.2096868437338735,
				-3.38951589996703
			]
			x: -15.233482566642351
			y: -44.37190016376451},
		SineOscModule {
			savedControlVolts: [
				-2.1969914925867418,
				-0.534947807288976
			]
			x: 19.944683532478848
			y: -146.98018632221692}
	]
	name: "new patch"}
