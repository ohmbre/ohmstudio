const Brig = require('brig');
const brig = new Brig();


brig.on('ready', function(brig) {

    const spawn = require('threads').spawn;
    const dsp = require('./dsp');
    
    var AudioThread = brig.createType('AudioThread', {
	property: { streamRep: "0" },
    });

    AudioThread.on('instance-created', function(instance) {
	instance.thread = spawn(function () {}).run(dsp.audioThread);
	instance.thread.send({ start: true, pwd: process.env.PWD });
	instance.on('streamRepChanged', function() {
	    instance.thread.send({streamRep: instance.getProperty('streamRep')});
	});
    });

    var dspMethods = {};
    for (var wrap in dsp.wraps)
	for (var i = 0; i < 10; i++)
	    dspMethods[wrap+'('+Array(i).fill('_').join(',')+')'] = dsp.wraps[wrap];
    for (var prop in dsp.props)
	brig.app.context.setContextProperty(prop,dsp.props[prop]);
    
    
    var Stream = brig.createType('DSP', {
	property: {},
    	method: dspMethods
    });
    
    var root = brig.createComponent();
    root.setData("import ohm 1.0; import Brig.DSP 1.0; DSP { property Ohm ohm: Ohm{} }");
    console.log(root.native.errors());
    var dspInstance = root.create();

});



    
