import ohm.cable 1.0
import ohm.patch 1.0
import ohm.module.envelope 1.0
import ohm.module.output 1.0
import ohm.module.clock 1.0
import ohm.module.cv 1.0
import ohm.module.logic 1.0

Patch {
	cables: [
		Cable {
			out: modules[0].jack("envelope")
			inp: modules[1].jack("trig")
		},
		Cable {
			inp: modules[0].jack("offset")
			out: modules[1].jack("out")
		}
	]
	modules: [
		ADModule {
			savedControlVolts: [
				0,
				0,
				0,
				0,
				0,
				0
			]
			x: 70.24983215332031
			y: -18.250442504882812},
		FlipFlopModule {
			savedControlVolts: []
			x: -59.25
			y: -45}
	]
	name: "new patch"}