.pragma library



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
    var fn = arguments[0];
    var generators = Array(arguments.length-1);
    for (var i = 1; i < arguments.length; i++)
	generators[i-1] = arguments[i];
    var vals = Array(generators.length);
    return function() {
	for (var g = 0; g < generators.length; g++) {
	    var gen = generators[g];
	    vals[g] = genval(gen);
	}
	return fn.apply(null, vals)
    }
}

function repeat() {
    var iarg = 0;
    var args = Array(arguments.length);
    for (var i = 0; i < arguments.length; i++)
	args[i] = arguments[i];
    return function() {
	var ret = args[iarg];
	iarg = (iarg+1) % args.length;
	return ret;
    }
}

function repeatArray(arr) {
    var iarg = 0;
    return function() {
	var ret = arr[iarg];
	iarg = (iarg + 1) % arr.length;
	return ret;
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
    var args = Array(arguments.length+1);
    args[0] = function (a,b) { return a+b; };
    for (var i = 0; i < arguments.length; i++)
	args[i+1] = arguments[i];
    return xmap.apply(null, args)
}

function mul() {
    var args = Array(arguments.length+1);
    args[0] = function (a,b) { return a*b; };
    for (var i = 0; i < arguments.length; i++)
	args[i+1] = arguments[i];
    return xmap.apply(null, args)
}

function sinusoid(freq) {
    return xmap(Math.sin, modulo(2*pi, freq));
}

function saw(freq) {
    return xmap(function (m) { return 5*v*(m/pi-1) }, modulo(2*pi,freq))
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

function clockSeq(trig,tstep,seqrepeat) {
    var seq = repeatArray(seqrepeat);
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

var lastStreamStr = null;
var stream = repeat(0);
var buf = ArrayBuffer(SAMPLE_BLOCK * SAMPLE_BYTES);
var samples = Float32Array(buf);

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
