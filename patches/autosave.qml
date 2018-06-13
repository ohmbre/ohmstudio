import ohm.cable 1.0
import ohm.patch 1.0
import ohm.module.audio 1.0
import ohm.module.vca 1.0
import ohm.module.mix 1.0
import ohm.module.multiple 1.0
import ohm.module.osc 1.0
import ohm.module.cv 1.0

Patch {
	cables: [
		Cable {
			inp: modules[0].jack("OutL")
			out: modules[1].jack("out")
		},
		Cable {
			out: modules[0].jack("InL")
			inp: modules[5].jack("input")
		},
		Cable {
			inp: modules[1].jack("in")
			out: modules[5].jack("output")
		}
	]
	modules: [
		AudioModule {
			savedControlVolts: []
			x: -19
			y: -49},
		VCAModule {
			savedControlVolts: [
				2.67144773006863,
				0.10966236637420756
			]
			x: 29
			y: -11},
		MixModule {
			savedControlVolts: []
			x: 65
			y: -58.999999999999886},
		MultipleModule {
			savedControlVolts: []
			x: -88.45258882819326
			y: -50.60842106136715},
		SineOscModule {
			savedControlVolts: [
				0,
				8.716153627299896
			]
			x: 18.975239791111335
			y: -93.96266092623199},
		SlideModule {
			savedControlVolts: [
				-4.202634356623383,
				0.3647938711076808
			]
			x: -26.218871395111478
			y: 3.347543480674176}
	]
	name: "new patch"}