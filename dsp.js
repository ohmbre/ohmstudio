module.exports = (function() {
   
    var prop = {}
    prop.sampleRate = 48000;
    prop.sampleBlock = 8192;
    prop.sampleBytes = 2;
    prop.sampleMin = -32767
    prop.sampleMax = 32767
    prop.voltsMin = -10
    prop.voltsMax = 10

    prop.pi = Math.PI
    prop.hz = 2*prop.pi/prop.sampleRate
    prop.v = (prop.sampleMax-prop.sampleMin)/(prop.voltsMax-prop.voltsMin)
    prop.s = prop.sampleRate
    prop.ms = prop.s/1000.0  

    var func = {};
    
    func.genval = function (gv) {
	return (gv instanceof Function) ? gv() : gv;
    }

    func.modulo = function (modulus, step) {
	var c = 0;
	return function() {
	    var ret = c;
	    c = (c + genval(step)) % modulus;
	    return ret;
	}
    }
    
    func.oneshot = function(trig,tstep,attack,decay) {
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
    func.xmap = function() {
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
    
    func.repeat = function() {
	var iarg = -1;
	var args = arguments.length === 1 ? [arguments[0]] : Array.apply(null, arguments);
	var nargs = args.length;
	return function() {
	    iarg = (iarg+1) % nargs;
	    return args[iarg];
	}
    }

    func.flatten = function() {
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
	
    func.cycle = function(tstep, hi_time, lo_time) {
	var t = 0;
	return function() {
	    var ht = genval(hi_time);
	    var state = (t < ht) ? 5 : 0
	    t += genval(tstep);
	    if (t > (ht + genval(lo_time))) t = 0;
	    return state;
	}
    }

    func.add = function() {
	var args = arguments.length === 1 ? [arguments[0]] : Array.apply(null,arguments);
	args.unshift(function (a,b) { return a+b });
	return xmap.apply(null, args)
    }
    
    func.mul = function() {
	var args = arguments.length === 1 ? [arguments[0]] : Array.apply(null,arguments);
	args.unshift(function (a,b) { return a*b })
	return xmap.apply(null, args)
    }

    func.round = function(frac) {
	return xmap(Math.round, frac);
    }

    func.max = function() {
	var args = arguments.length === 1 ? [arguments[0]] : Array.apply(null,arguments);
	args.unshift(Math.max)
	return xmap.apply(null, args);
    }

    func.min = function() {
	var args = arguments.length === 1 ? [arguments[0]] : Array.apply(null,arguments);
	args.unshift(Math.max)
	return xmap.apply(null, args);
    }
    
    func.sinusoid = function(freq) {
	return xmap(Math.sin, modulo(2*pi, freq));
    }
		
    func.saw = function(freq) {
	return xmap(function (m) { return m - 1 }, modulo(2,freq))
    }
    
    func.pow2 = function(x) {
	return xmap(function (a) { return Math.pow(2, a) }, x);
    }

    func.index = function(lst,idx) {
	return function() {
	    if (lst instanceof Array)
		return lst[genval(idx)];
	    return Object.entries(lst)[genval(idx)][1];
	}
    }
    
    func.sample = function(lst,k) {
	var subsample = [];
	for (var i = 0; i < k; i++)
	    subsample.push(lst[Math.floor(Math.random() * lst.length)]);
	return subsample;
    }

    func.seededSample = function(lst, k, seed) {
	var subsample = [];
	seed = genval(seed);
	k = genval(k);
	for (var i = 0; i < k; i++) {
	    seed = (seed * 279470273) % 0xfffffffb;
	    subsample.push(lst[seed % lst.length]);
	}
	return subsample;
    }
    
    func.clockSeq = function(trig,tstep,seqrepeat) {
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

    func.scaleStep = Math.pow(2,1.0/12)
    func.noteToHz = function(note, octave) {
	return 440*hz*Math.pow(scaleStep, (octave-4)*12 + note);
    }

    func.scaleToVoct = function(scale) {
	scale = genval(scale);
	var voltages = [];
	for (var i = 0; i < scale.length; i++)
	    voltages.push(Math.log(scale[i])/Math.log(2))
	return voltages;
    }

    var wraps = {}
    for (var fn in func)
	(function(fnLocal) {
	    wraps[fnLocal] = function() {
		var ret = fnLocal + "(";
		if (arguments.length) {
		    ret += arguments[0];
		    for (var i = 1; i < arguments.length; i++)
			ret += ','+arguments[i];
		}
		ret += ')';
		return ret;
	    }
	})(fn);
    this.wraps = wraps;

    this.notes = {C:-9,Cs:-8,Db:-8,D:-7,Ds:-6,Eb:-6,E:-5,F:-4,Fs:-3,Gb:-3,G:-2,Gs:-1,Ab:-1,A:0,As:1,Bb:1,B:2};
    for (var note in this.notes)
	prop[note] = this.notes[note];
    
    var scales = {
	minor: [1,9/8,6/5,27/20,3/2,8/5,9/5],
	locrian: [1,16/15,6/5,4/3,64/45,8/5,16/9],
	major: [1,9/8,5/4,4/3,3/2,5/3,15/8],
	dorian: [1,10/9,32/27,4/3,40/27,5/3,16/9],
	phrygian: [1,16/15,6/5,4/3,3/2,8/5,9/5],
	lydian: [1,9/8,5/4,45/32,3/2,27/16,15/8],
	mixolydian: [1,10/9,5/4,4/3,3/2,5/3,16/9],
	minorPentatonic: [1,6/5,27/20,3/2,9/5],
	majorPentatonic: [1,9/8,5/4,3/2,5/3],
	egyptian: [1,10/9,4/3,40/27,16/9],
	minorBlues: [1,6/5,4/3,8/5,9/5],
	majorBlues: [1,10/9,4/3,3/2,5/3]
    }
    
    this.literals = {};
    for (scale in scales)
	this.literals[scale] = scales[scale];
    this.literals.scales = 'scales';
    
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
		console.log("new stream: "+lastStreamRep);
		with(dsp) { stream = eval(lastStreamRep) }

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

    for (var property in func) this[property] = func[property];
    for (var property in prop) this[property] = prop[property];
    for (var property in literals) this[property] = literals[property];
    this.props = prop;
    this.scales = scales;
    
    return this;

})();


