import ohm 1.0
import modules 1.0

Patch {
	cables: [
		Cable {
			out: modules[1].jack("clkout")
			inp: modules[4].jack("in")
		},
		Cable {
			out: modules[5].jack("clkout")
			inp: modules[7].jack("gate")
		},
		Cable {
			out: modules[8].jack("signal")
			inp: modules[10].jack("in2")
		},
		Cable {
			out: modules[7].jack("envelope")
			inp: modules[12].jack("gain")
		},
		Cable {
			out: modules[12].jack("signal")
			inp: modules[14].jack("in2")
		},
		Cable {
			out: modules[13].jack("signal")
			inp: modules[14].jack("in1")
		},
		Cable {
			out: modules[10].jack("out")
			inp: modules[15].jack("in")
		},
		Cable {
			inp: modules[11].jack("in")
			out: modules[15].jack("out")
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
			inp: modules[2].jack("clkin")
			out: modules[3].jack("out1")
		},
		Cable {
			out: modules[2].jack("clkout")
			inp: modules[16].jack("gate")
		},
		Cable {
			inp: modules[9].jack("outR")
			out: modules[11].jack("out2")
		},
		Cable {
			inp: modules[9].jack("outL")
			out: modules[11].jack("out1")
		},
		Cable {
			out: modules[4].jack("out4")
			inp: modules[6].jack("gate")
		},
		Cable {
			out: modules[4].jack("out3")
			inp: modules[17].jack("gate")
		},
		Cable {
			inp: modules[3].jack("in")
			out: modules[18].jack("clkout")
		},
		Cable {
			out: modules[0].jack("trig")
			inp: modules[19].jack("in")
		},
		Cable {
			inp: modules[18].jack("clkin")
			out: modules[19].jack("out4")
		},
		Cable {
			out: modules[14].jack("out")
			inp: modules[21].jack("in2")
		},
		Cable {
			inp: modules[10].jack("in1")
			out: modules[21].jack("out")
		},
		Cable {
			out: modules[6].jack("envelope")
			inp: modules[23].jack("in")
		},
		Cable {
			inp: modules[8].jack("gain")
			out: modules[23].jack("out2")
		},
		Cable {
			inp: modules[8].jack("v/oct")
			out: modules[17].jack("envelope")
		},
		Cable {
			out: modules[19].jack("out1")
			inp: modules[22].jack("clkin")
		},
		Cable {
			inp: modules[13].jack("gain")
			out: modules[16].jack("envelope")
		},
		Cable {
			inp: modules[20].jack("clock")
			out: modules[26].jack("out3")
		},
		Cable {
			out: modules[22].jack("clkout")
			inp: modules[26].jack("in")
		},
		Cable {
			out: modules[24].jack("envelope")
			inp: modules[27].jack("gain")
		},
		Cable {
			out: modules[19].jack("out2")
			inp: modules[24].jack("gate")
		},
		Cable {
			out: modules[20].jack("v/oct")
			inp: modules[29].jack("in")
		},
		Cable {
			inp: modules[28].jack("v/oct")
			out: modules[29].jack("out3")
		},
		Cable {
			out: modules[28].jack("signal")
			inp: modules[30].jack("in1")
		},
		Cable {
			out: modules[27].jack("signal")
			inp: modules[30].jack("in2")
		},
		Cable {
			inp: modules[21].jack("in1")
			out: modules[30].jack("out")
		},
		Cable {
			out: modules[26].jack("out2")
			inp: modules[31].jack("gate")
		},
		Cable {
			inp: modules[28].jack("gain")
			out: modules[31].jack("envelope")
		},
		Cable {
			inp: modules[27].jack("v/oct")
			out: modules[29].jack("out4")
		},
		Cable {
			out: modules[25].jack("signal")
			inp: modules[32].jack("in")
		},
		Cable {
			inp: modules[27].jack("duty")
			out: modules[32].jack("out4")
		},
		Cable {
			inp: modules[20].jack("randseed")
			out: modules[32].jack("out2")
		},
		Cable {
			inp: modules[25].jack("gain")
			out: modules[33].jack("signal")
		}
	]
	modules: [
		ClockModule {
			savedControlVolts: [
				7.562818460288604
			]
			x: -181.4213324200266
			y: 30.788548423749944},
		ClockDividerModule {
			savedControlVolts: [
				-6,
				0
			]
			x: -46.381438136909765
			y: -29.395760869547985},
		ClockDividerModule {
			savedControlVolts: [
				-8,
				1
			]
			x: -26.312171490103765
			y: 92.3932254413445},
		MultipleModule {
			savedControlVolts: []
			x: -71.70371926692201
			y: 31.674684673592765},
		MultipleModule {
			savedControlVolts: []
			x: -14.034760128697599
			y: 7.785928175116396},
		ClockDividerModule {
			savedControlVolts: [
				-8,
				0
			]
			x: 30.25649652382367
			y: 58.355277070142165},
		ADModule {
			savedControlVolts: [
				-8.13806601350122,
				3.2009837791933275,
				1.7536906352603783,
				-0.6903264992985783,
				7.254593475641752,
				0.015764686826386765
			]
			x: 106.83723481517063
			y: -74.145334457118},
		ADModule {
			savedControlVolts: [
				-9.236540921146034,
				7.5373807310339025,
				0.8647356174426477,
				2.7189588408422143,
				8.551087737365915,
				-9.40005866798217
			]
			x: 81.64888881456068
			y: 12.621396488392634},
		SineOscModule {
			savedControlVolts: [
				-10,
				-10
			]
			x: 246.14299731531162
			y: -47.362027521765754},
		AudioCodecModule {
			savedControlVolts: []
			x: 380.95121667379885
			y: 24.518143869673168},
		MixModule {
			savedControlVolts: []
			x: 231.64895651901202
			y: 47.23089356593289},
		MultipleModule {
			savedControlVolts: []
			x: 300.9853429918471
			y: 8.911089337987505},
		RandomNoiseModule {
			savedControlVolts: [
				-10,
				-3
			]
			x: 145.34023907422625
			y: 35.25430119880741},
		RandomNoiseModule {
			savedControlVolts: [
				-10,
				-7
			]
			x: 90.27425733719576
			y: 89.40981407268123},
		MixModule {
			savedControlVolts: []
			x: 171.7698914175262
			y: 92.63962841310376},
		VCAModule {
			savedControlVolts: [
				0.06359432313675484,
				0
			]
			x: 266.35824245015215
			y: 100.99510607726279},
		ADModule {
			savedControlVolts: [
				0.6194957914927421,
				1.4926861224840877,
				0.015155522386580245,
				1.4436381572941066,
				8.339740354219408,
				-10
			]
			x: 11.627512759304182
			y: 129.35967425527315},
		ADModule {
			savedControlVolts: [
				-7.7354000851132465,
				2.8092092221132816,
				2.0237590260251803,
				-2.2217783801045243,
				4.102657661638409,
				0.829624845759632
			]
			x: 81.95960583512351
			y: -31.706162586839923},
		ClockDividerModule {
			savedControlVolts: [
				-8,
				0
			]
			x: -113.90719042343619
			y: 82.0578184901957},
		MultipleModule {
			savedControlVolts: []
			x: -137.4913471490197
			y: 144.70597982044558},
		RandSeqModule {
			savedControlVolts: [
				-5,
				-5.559623847999669,
				-5.625,
				0
			]
			x: 50.29939346106278
			y: 221.74405048566973},
		MixModule {
			savedControlVolts: []
			x: 226.86160667180388
			y: 137.27269890369985},
		ClockDividerModule {
			savedControlVolts: [
				-8,
				-4
			]
			x: -92.54592663024982
			y: 203.9032894895223},
		MultipleModule {
			savedControlVolts: []
			x: 174.50600817431655
			y: -49.86219827486764},
		ADModule {
			savedControlVolts: [
				-2.741959912337685,
				-0.675170976911998,
				-1.4775306000975057,
				-1.4145454414005592,
				5.265336056859784,
				5.534259707353566
			]
			x: -51.74525330770189
			y: 152.51546080982985},
		SineOscModule {
			savedControlVolts: [
				-8.41605354198351,
				2.187276772861317
			]
			x: -10.332503504421084
			y: 210.17355456808014},
		MultipleModule {
			savedControlVolts: []
			x: -20.618221670284356
			y: 253.9998776438265},
		PwmOscModule {
			savedControlVolts: [
				-0.7278739287408236,
				1.0227708843205185,
				-10
			]
			x: 135.4245896741711
			y: 165.70124203607747},
		SineOscModule {
			savedControlVolts: [
				-1.6059375752506266,
				-8.153830700327605
			]
			x: 189.3519461702524
			y: 252.17556257162687},
		MultipleModule {
			savedControlVolts: []
			x: 122.41831019390418
			y: 234.00880854445677},
		MixModule {
			savedControlVolts: []
			x: 202.73163188891272
			y: 180.5713687701832},
		ADModule {
			savedControlVolts: [
				-6.467315786234226,
				1.1965708380247797,
				2.1255099430439834,
				-0.01690942709740284,
				8.996174410714588,
				-10
			]
			x: 105.077281822842
			y: 269.6267098087244},
		MultipleModule {
			savedControlVolts: []
			x: 63.990260538928624
			y: 176.2934366815084},
		SineOscModule {
			savedControlVolts: [
				-10,
				0.310052477966277
			]
			x: -101.92280071243715
			y: 254.60504225123736}
	]
	name: "new patch"}
