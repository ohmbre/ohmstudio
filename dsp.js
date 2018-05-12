module.exports = (function() {
    
    this.sampleRate = 48000;
    this.sampleBlock = 8192;
    this.sampleBytes = 2;
    this.sampleMin = -32767
    this.sampleMax = 32767
    this.voltsMin = -10
    this.voltsMax = 10

    this.pi = Math.PI
    this.hz = 2*pi/sampleRate
    this.v = (sampleMax-sampleMin)/(voltsMax-voltsMin)
    this.s = sampleRate
    this.ms = s/1000.0  

    this.genval = function (gv) {
	return (gv instanceof Function) ? gv() : gv;
    }

    this.modulo = function (modulus, step) {
	var c = 0;
	return function() {
	    var ret = c;
	    c = (c + genval(step)) % modulus;
	    return ret;
	}
    }
    
    this.oneshot = function(trig,tstep,attack,decay) {
	var pos = 0, gate = false, slope = 0;
	return function() {
	    var t = genval(trig);
	    if (!gate && t > 3) {
		gate = true;
		slope = (1-pos)/genval(attack);
	    } else if (gate && t < 1) {
		gate = false;
		slope = -pos/genval(decay);
	    }
	    var ret = pos;
	    pos += slope * genval(tstep);
	    if (pos > 1) pos = 1
	    if (pos < 0) pos = 0
	    return ret;
	}
    }
    
    // xmap(fn, generator1, generator2, ...) => fn(generator1, generator2, ...)
    this.xmap = function() {
	var gens = Array.apply(null, arguments);
	var fn = gens.shift()
	var ngens = gens.length;
	var vals = new Array(gens.length);
	return function() {
	    for (var g = 0; g < ngens; g++)
		vals[g] = genval(gens[g]);
	    return fn.apply(null, vals)
	}
    }
    
    this.repeat = function() {
	var iarg = -1;
	var args = arguments.length === 1 ? [arguments[0]] : Array.apply(null, arguments);
	var nargs = args.length;
	return function() {
	    iarg = (iarg+1) % nargs;
	    return args[iarg];
	}
    }

    this.flatten = function() {
	var args = arguments.length === 1 ? [arguments[0]] : Array.apply(null,arguments)
	var nargs = args.lenth;
	var iarg = 0,nsub = args[0].length,isub = 0;
	return function() {
	    if (isub < nsub)
		return args[iarg][isub++];
	    iarg = (iarg+1) % nargs;
	    isub = 0;
	    nsub = args[iarg].length;
	}
    }
	
    this.cycle = function(tstep, hi_time, lo_time) {
	var t = 0;
	return function() {
	    var ht = genval(hi_time);
	    var state = (t < ht) ? 5 : 0
	    t += genval(tstep);
	    if (t > (ht + genval(lo_time))) t = 0;
	    return state;
	}
    }

    this.add = function() {
	var args = arguments.length === 1 ? [arguments[0]] : Array.apply(null,arguments);
	args.unshift(function (a,b) { return a+b });
	return xmap.apply(null, args)
    }
    
    this.mul = function() {
	var args = arguments.length === 1 ? [arguments[0]] : Array.apply(null,arguments);
	args.unshift(function (a,b) { return a*b })
	return xmap.apply(null, args)
    }
    
    this.sinusoid = function(freq) {
	return xmap(Math.sin, modulo(2*pi, freq));
    }
		
    this.saw = function(freq) {
	var slope = 5*v/pi;
	var intercept = 5*v;
	return xmap(function (m) { return slope*m - intercept }, modulo(2*pi,freq))
    }
    
    this.pow2 = function(x) {
	return xmap(function (a) { return Math.pow(2, a) }, x);
    }
    
    this.sample = function(lst,k) {
	var subsample = [];
	for (var i = 0; i < k; i++)
	    subsample.push(lst[Math.floor(Math.random() * lst.length)]);
	return subsample;
    }
    
    this.clockSeq = function(trig,tstep,seqrepeat) {
	var seq = repeat.apply(null,seqrepeat);
	var gate = false;
	var val = seq();
	return function() {
	    var t = genval(trig)
	    if (!gate && t > 3) {
		gate = true;
		val = seq();
	    } else if (gate && t < 1) {
		gate = false;
	    }
	    return val;
	}
    }

    this.notes = {C:-9,Cs:-8,Db:-8,D:-7,Ds:-6,Eb:-6,E:-5,F:-4,Fs:-3,Gb:-3,G:-2,Gs:-1,Ab:-1,A:0,As:1,Bb:1,B:2};
    for (var note in notes)
	this[note] = notes[note];

    this.scaleStep = Math.pow(2,1.0/12)
    this.noteToHz = function(note, octave) {
	return 440*hz*Math.pow(scaleStep, (octave-4)*12 + note);
    }
    
    this.minor = [1,9/8,6/5,27/20,3/2,8/5,9/5];
    this.locrian = [1,16/15,6/5,4/3,64/45,8/5,16/9];
    this.major = [1,9/8,5/4,4/3,3/2,5/3,15/8];
    this.dorian = [1,10/9,32/27,4/3,40/27,5/3,16/9];
    this.phrygian = [1,16/15,6/5,4/3,3/2,8/5,9/5];
    this.lydian = [1,9/8,5/4,45/32,3/2,27/16,15/8];
    this.mixolydian = [1,10/9,5/4,4/3,3/2,5/3,16/9];
    this.minorPentatonic = [1,6/5,27/20,3/2,9/5];
    this.majorPentatonic = [1,9/8,5/4,3/2,5/3];
    this.egyptian = [1,10/9,4/3,40/27,16/9];
    this.minorBlues = [1,6/5,4/3,8/5,9/5];
    this.majorBlues = [1,10/9,4/3,3/2,5/3];
    
    this.scaleToVoct = function(scale) {
	var voltages = [];
	for (var i = 0; i < scale.length; i++)
	    voltages.push(Math.log(scale[i])/Math.log(2))
	return voltages;
    }

    this.audioThread = function(message) {
	var local = this;
	if (message.streamRep) local.streamRep = message.streamRep;
	if (message.pwd) local.pwd = message.pwd;
	if (!message.start) return;
	if (!local.pwd) return;
	if (!local.streamRep) local.streamRep = 'repeat(0)';
	
	var dsp = require(local.pwd+'/dsp.js');
	
	var stream;
	var lastStreamRep;
	
	const Speaker = require('speaker');
	const Readable = require('stream').Readable;
	const Buffer = require('buffer').Buffer
	
	var arrayBuf = new ArrayBuffer(dsp.sampleBlock * dsp.sampleBytes);
	var samples = new Int16Array(arrayBuf);
	var buffer = Buffer(arrayBuf);
	
	const output = new Readable();
	output._read = function (chunkByteSize) {
	    if (local.streamRep != lastStreamRep) {
		lastStreamRep = local.streamRep;
		with(dsp) { stream = eval(lastStreamRep) }
		console.log("new stream: "+lastStreamRep);
	    }
	    var nSamples = chunkByteSize / dsp.sampleBytes;
	    for (var i = 0; i < nSamples; i++)
		samples[i] = Math.round(stream());
	    this.push(buffer);
	}
	var speaker = new Speaker({channels: 1, bitDepth: dsp.sampleBytes*8, sampleRate: dsp.sampleRate,
				   float: false, samplesPerFrame: dsp.sampleBlock, signed: true});
	output.pipe(speaker);	
    }

    return this;

})();


