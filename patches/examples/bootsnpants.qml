import ohm.cable 1.0
import ohm.patch 1.0
import ohm.module.logic 1.0
import ohm.module.envelope 1.0
import ohm.module.osc 1.0
import ohm.module.output 1.0
import ohm.module.clock 1.0
import ohm.module.multiple 1.0
import ohm.module.mix 1.0
import ohm.module.noise 1.0
import ohm.module.vca 1.0

Patch {
	cables: [
		Cable {
			out: modules[0].jack("trig")
			inp: modules[3].jack("in")
		},
		Cable {
			out: modules[1].jack("clkout")
			inp: modules[4].jack("in")
		},
		Cable {
			out: modules[5].jack("clkout")
			inp: modules[7].jack("gate")
		},
		Cable {
			out: modules[6].jack("envelope")
			inp: modules[9].jack("in")
		},
		Cable {
			inp: modules[8].jack("v/oct")
			out: modules[9].jack("out2")
		},
		Cable {
			inp: modules[8].jack("gain")
			out: modules[9].jack("out3")
		},
		Cable {
			out: modules[8].jack("signal")
			inp: modules[11].jack("in2")
		},
		Cable {
			out: modules[7].jack("envelope")
			inp: modules[13].jack("gain")
		},
		Cable {
			out: modules[13].jack("signal")
			inp: modules[15].jack("in2")
		},
		Cable {
			out: modules[14].jack("signal")
			inp: modules[15].jack("in1")
		},
		Cable {
			inp: modules[11].jack("in1")
			out: modules[15].jack("out")
		},
		Cable {
			out: modules[11].jack("out")
			inp: modules[16].jack("in")
		},
		Cable {
			inp: modules[12].jack("in")
			out: modules[16].jack("out")
		},
		Cable {
			out: modules[4].jack("out3")
			inp: modules[6].jack("gate")
		},
		Cable {
			out: modules[4].jack("out2")
			inp: modules[5].jack("clkin")
		},
		Cable {
			inp: modules[1].jack("clkin")
			out: modules[3].jack("out4")
		},
		Cable {
			inp: modules[10].jack("outL")
			out: modules[12].jack("out1")
		},
		Cable {
			inp: modules[10].jack("outR")
			out: modules[12].jack("out2")
		},
		Cable {
			inp: modules[2].jack("clkin")
			out: modules[3].jack("out1")
		},
		Cable {
			out: modules[2].jack("clkout")
			inp: modules[17].jack("gate")
		},
		Cable {
			inp: modules[14].jack("gain")
			out: modules[17].jack("envelope")
		},
		Cable {
			out: modules[9].jack("out1")
			inp: modules[14].jack("seed")
		}
	]
	modules: [
		ClockModule {
			savedControlVolts: [
				8.587416837928544
			]
			x: -120.78266470764902
			y: 1.285150382852862},
		ClockDividerModule {
			savedControlVolts: [
				-6,
				0
			]
			x: -46.381438136909765
			y: -29.395760869547985},
		ClockDividerModule {
			savedControlVolts: [
				-6,
				1
			]
			x: -30.15168111920275
			y: 83.65986217575983},
		MultipleModule {
			savedControlVolts: []
			x: -71.70371926692201
			y: 31.674684673592765},
		MultipleModule {
			savedControlVolts: []
			x: -10.835111973787662
			y: 13.7218947875308},
		ClockDividerModule {
			savedControlVolts: [
				-8,
				0
			]
			x: 30.25649652382367
			y: 58.355277070142165},
		ADModule {
			savedControlVolts: [
				-6.160918294906795,
				2.602735154485236,
				-1.0929924276865481,
				-0.6109674893354384,
				6.3239004659117235,
				-1.8118024784388673
			]
			x: 46.024753153461006
			y: -41.10271436347227},
		ADModule {
			savedControlVolts: [
				-3.187046585686357,
				1.7167523702579413,
				1.2650384766799867,
				0.543791768168445,
				6.179119639492413,
				0
			]
			x: 72.1830943261698
			y: 17.105193877630427},
		SineOscModule {
			savedControlVolts: [
				-10,
				-6.177901310612794
			]
			x: 183.50381750242695
			y: -20.057847371570688},
		MultipleModule {
			savedControlVolts: []
			x: 105.097686735622
			y: -12.680349735961954},
		AudioCodecModule {
			savedControlVolts: []
			x: 378.303584522223
			y: 20.621062868402078},
		MixModule {
			savedControlVolts: []
			x: 240.47482515570505
			y: 32.255738418316014},
		MultipleModule {
			savedControlVolts: []
			x: 304.3427781581313
			y: -1.5808955566503755},
		RandomNoiseModule {
			savedControlVolts: [
				-10,
				-3
			]
			x: 153.69887906516692
			y: 35.90478914045036},
		RandomNoiseModule {
			savedControlVolts: [
				-10,
				10
			]
			x: 100.5046089395023
			y: 75.91397242193455},
		MixModule {
			savedControlVolts: []
			x: 180.9434593209669
			y: 87.50575066417264},
		VCAModule {
			savedControlVolts: [
				1.4594028441204934,
				0
			]
			x: 280.59796116773623
			y: 69.912250882433},
		ADModule {
			savedControlVolts: [
				0.7666396870626855,
				-0.555292303916179,
				-0.5661836752241083,
				-1.3794346697175435,
				7.106840415632,
				-10
			]
			x: 30.57823879569139
			y: 121.23312454369534}
	]
	name: "new patch"}