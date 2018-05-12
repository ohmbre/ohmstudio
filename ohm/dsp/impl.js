


function genval(gv) {
    return (gv instanceof Function) ? gv() : gv;
}

function modulo(modulus, step) {
    var c = 0;
    return function() {
	var ret = c;
	c = (c + genval(step)) % modulus;
	return ret;
    }
}

function oneshot(trig,tstep,attack,decay) {
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
function xmap() {
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

function repeat() {
    var iarg = -1;
    var args = arguments.length === 1 ? [arguments[0]] : Array.apply(null, arguments);
    var nargs = args.length;
    return function() {
	iarg = (iarg+1) % nargs;
	return args[iarg];
    }
}

function flatten() {
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
	
function cycle(tstep, hi_time, lo_time) {
    var t = 0;
    return function() {
	var ht = genval(hi_time);
	var state = (t < ht) ? 5 : 0
	t += genval(tstep);
	if (t > (ht + genval(lo_time))) t = 0;
	return state;
    }
}

function add() {
    var args = arguments.length === 1 ? [arguments[0]] : Array.apply(null,arguments);
    args.unshift(function (a,b) { return a+b });
    return xmap.apply(null, args)
}

function mul() {
    var args = arguments.length === 1 ? [arguments[0]] : Array.apply(null,arguments);
    args.unshift(function (a,b) { return a*b })
    return xmap.apply(null, args)
}

function sinusoid(freq) {
    return xmap(Math.sin, modulo(2*pi, freq));
}

function saw(freq) {
    var slope = 5*v/pi;
    var intercept = 5*v;
    return xmap(function (m) { return slope*m - intercept }, modulo(2*pi,freq))
}

function pow2(x) {
    return xmap(function (a) { return Math.pow(2, a) }, x);
}

function sample(lst,k) {
    var subsample = [];
    for (var i = 0; i < k; i++)
	subsample.push(lst[Math.floor(Math.random() * lst.length)]);
    return subsample;
}

function clockSeq(trig,tstep,seqrepeat) {
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

var C=-9,Cs=-8,Db=Cs,D=-7,Ds=-6,Eb=Ds,E=-5,F=-4,Fs=-3,Gb=Fs,G=-2,Gs=-1,Ab=Gs,A=0,As=1,Bb=As,B=2;

var scaleStep = Math.pow(2,1.0/12)
function noteToHz(note, octave) {
    return 440*hz*Math.pow(scaleStep, (octave-4)*12 + note);
}

var minor = [1,9/8,6/5,27/20,3/2,8/5,9/5];
var locrian = [1,16/15,6/5,4/3,64/45,8/5,16/9];
var major = [1,9/8,5/4,4/3,3/2,5/3,15/8];
var dorian = [1,10/9,32/27,4/3,40/27,5/3,16/9];
var phrygian = [1,16/15,6/5,4/3,3/2,8/5,9/5];
var lydian = [1,9/8,5/4,45/32,3/2,27/16,15/8];
var mixolydian = [1,10/9,5/4,4/3,3/2,5/3,16/9];
var minorPentatonic = [1,6/5,27/20,3/2,9/5];
var majorPentatonic = [1,9/8,5/4,3/2,5/3];
var egyptian = [1,10/9,4/3,40/27,16/9];
var minorBlues = [1,6/5,4/3,8/5,9/5];
var majorBlues = [1,10/9,4/3,3/2,5/3];

function scaleToVoct(scale) {
    var voltages = [];
    for (var i = 0; i < scale.length; i++)
	voltages.push(Math.log(scale[i])/Math.log(2))
    return voltages;
}



var lastStreamStr = null;
var stream = repeat(0);
//var buf = ArrayBuffer(SAMPLE_BLOCK * SAMPLE_BYTES);
var samples = new Float32Array(SAMPLE_BLOCK); //buf);

while (true) {
    if (audio.streamStr != lastStreamStr) {
	lastStreamStr = audio.streamStr;
	stream = eval(audio.streamStr);
	console.log(lastStreamStr)
    }
    var i;
    for (i = 0; i < SAMPLE_BLOCK; i++)
	samples[i] = stream();
    
    audio.write(buf)
}
