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
			out: modules[4].jack("trig")
			inp: modules[5].jack("gate")
		},
		Cable {
			out: modules[5].jack("envelope")
			inp: modules[6].jack("in")
		},
		Cable {
			inp: modules[2].jack("gain")
			out: modules[6].jack("out1")
		},
		Cable {
			inp: modules[2].jack("in")
			out: modules[3].jack("signal")
		},
		Cable {
			out: modules[6].jack("out2")
			inp: modules[10].jack("in")
		},
		Cable {
			inp: modules[1].jack("v/oct")
			out: modules[10].jack("out")
		},
		Cable {
			out: modules[1].jack("signal")
			inp: modules[7].jack("in1")
		},
		Cable {
			out: modules[2].jack("out")
			inp: modules[7].jack("in2")
		},
		Cable {
			inp: modules[0].jack("L")
			out: modules[7].jack("out")
		}
	]
	modules: [
		AudioModule {
			savedControlVolts: []
			x: 97.95738840498052
			y: 85.50544588639059},
		SineOscModule {
			savedControlVolts: [
				-3.6341228812770736,
				5
			]
			x: 35.62627609102071
			y: -66.1457248610202},
		VCAModule {
			savedControlVolts: [
				-0.3862005667691708,
				0.042000315158878365
			]
			x: 46.61448652682566
			y: 6.271072994804399},
		SineOscModule {
			savedControlVolts: [
				-3.407205550344923,
				-0.10618882389134665
			]
			x: 22.706725348537248
			y: 105.14719502057119},
		ClockModule {
			savedControlVolts: [
				-0.005168379543984969
			]
			x: -88.5
			y: 31.5},
		ADModule {
			savedControlVolts: [
				-5,
				0.6302417706227743,
				-0.0017227931813295072,
				0.5600234857556519
			]
			x: -55.38356908538117
			y: 72.01437139352504},
		MultipleModule {
			savedControlVolts: []
			x: -6.551244184977463
			y: 24.28468020854848},
		MixModule {
			savedControlVolts: []
			x: 90.93805334998774
			y: -0.9712400749453991},
		MultipleModule {
			savedControlVolts: []
			x: 36.35476453592685
			y: -126.64702041687178},
		MultipleModule {
			savedControlVolts: []
			x: 144.16443498658907
			y: -49.88452896205513},
		VCAModule {
			savedControlVolts: [
				3.0723766023401,
				-3.2128131720743385
			]
			x: -2.942887030198108
			y: -31.504932549611567}
	]
	name: "new patch"}
