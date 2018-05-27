const Brig = require('brig');
brig = new Brig();


brig.on('ready', function(brig) {

    const cp = require('child_process');
    
    var AudioThread = brig.createType('AudioThread', {
	property: { eqnL: '0' , eqnR: '0'}
    });

    AudioThread.on('instance-created', function(instance) {
	instance.subproc = cp.fork('./audio.js');

	instance.on('eqnLChanged', function() {
	    instance.subproc.send('streams[0]='+instance.getProperty('eqnL'));
	});
	instance.on('eqnRChanged', function() {
	    instance.subproc.send('streams[1]='+instance.getProperty('eqnR'));
	});
    });

    var root = brig.createComponent();
    root.setData("import ohm 1.0; Ohm{}");
    var errors = root.native.errors();
    if (errors.length) console.log(errors);
    var ohm = root.create();

});


    
