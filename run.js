var Brig = require('brig');
var brig = new Brig();

const spawn = require('threads').spawn;

brig.on('ready', function(brig) {
    brig.app.context.setContextProperty('v',1.0/10);
    brig.app.context.setContextProperty('ms',48);

    var AudioThread = brig.createType('AudioThread', {
	property: { streamRep: "0" },
    });

    AudioThread.on('instance-created', function(instance) {
	instance.thread = spawn(function () {}).run(require('./dsp').audioThread);
	instance.thread.send({ start: true, pwd: process.env.PWD });
	instance.on('streamRepChanged', function() {
	    instance.thread.send({streamRep: instance.getProperty('streamRep')});
	});
    });
    
    var root = brig.createComponent();
    root.setData("import ohm 1.0; Ohm{}");
    var window = root.create();
});



    
