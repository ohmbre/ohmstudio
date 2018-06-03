

const alsa = require('alsa');
math = require('mathjs');

const device = "hw:0,0"
const sampleRate = 48000
const sampleSigned = true
const sampleBytes = 4
const samplePeriod = 512
const sampleBuffer = 4096
const sampleBits = 8 * sampleBytes
const sampleMax = Math.pow(2,sampleBits)/(sampleSigned ? 2 : 1) -1
const sampleMin = sampleSigned ? -sampleMax : 0
const vMax = 10
const vMin = -10
const vScale = (sampleMax-sampleMin)/(vMax-vMin)

ohmConstants = {
    s:sampleRate, ms:sampleRate/1000, mins:60*sampleRate,
    hz:math.tau/sampleRate, v:1,
    C:-9, Cs:-8, Db:-8, D:-7, Ds:-6, Eb:-6,F:-4,Fs:-3,Gb:-3,G:-2,Gs:-1,Ab:-1,A:0,As:1,Bb:1,B:2
}

//notehz = math.eval('notehz(name,octave)=440hz*(2^(1/12))^((octave-4)*12+name)')
math.import({
    notehz:(name,octave)=>0.05759586531581288*Math.pow(1.0594630943592953,(octave-4)*12+name)
})

class Ohmutable {
    constructor(vinitial) {
	this.val=vinitial;
    }
    update() {}
    [Symbol.toPrimitive]() {
	this.update();
	return this.val;
    }
    toString() {
	return `Ohmutable(val=${this.val})`
    }
}

class Composite extends Ohmutable{
    constructor(fn,...args) {
	super(0)
	this.args = args
	this.fn=fn
	this.update()
    }
    update() {
	var argvals = this.args.map((arg)=>+arg)
	this.val = this.fn(...argvals)
    }
    toString() {
	return `${this.fn.name}(${this.args.map((arg)=>arg.toString()).join(',')})`
    }
}

class Genny extends Ohmutable {
    constructor(...args) {
	super(0)
	this.t = 0
	this.gen = this.genFunc(...args)
	this.val = this.gen.next().value
    }
    update() {
	if (this.t < globaltime.val) {
	    this.t = globaltime.val;
	    this.val = this.gen.next().value
	}
    }
}

class Sinusoid extends Genny{
    *genFunc(freq) {
	this.phase = 0;
	this.freq=freq
	while (true) {
	    yield Math.sin(this.phase);
	    this.phase += this.freq;
	}
    }
    toString() {
	return `Sinusoid(t=${this.t} val=${this.val} freq=${this.freq.toString()})`
    }
}

math.typed.types.splice(1,0,{
    name: 'Ohmutable',
    test: (x) => x instanceof Ohmutable
})

const streams = [math.compile(0),math.compile(0)];
const audioCard = alsa.Sound(device, sampleRate, samplePeriod, sampleBuffer);

const globaltime = new Ohmutable(0)
const ohmutables = {
    'sinusoid': function(freq){ return new Sinusoid(freq) },
    'composite': function(a,b,fn) { return new Composite(a, b, fn) }
}
math.import(ohmutables, {wrap:false});

ohmsigs = {}
math.forEach(Object.keys(math),function(func){
    if (math[func] && math[func].signatures && 'number,number' in math[func].signatures)
    	ohmsigs[func] = math.typed(func,{
	    'Ohmutable,any': (...args)=> math.composite(math[func],...args),
	    'any,Ohmutable': (...args)=> math.composite(math[func],...args),
	});
});
ohmsigs['unaryMinus'] = math.typed('unaryMinus',{
    'Ohmutable': (negated) => math.composite(math.multiply, -1, negated)
});
math.import(ohmsigs,{wrap:false});

var sampcnt = 0, sampn = 0;

function writeOut() {
    var samples = audioCard.writeBuffer()
    var nsamples = samples.length, i = 0
    while (i < nsamples) {
	samples[i++] = Math.round(vScale*streams[0].eval());
	samples[i++] = Math.round(vScale*streams[1].eval());
	globaltime.val++
    }
    audioCard.commit()
    sampcnt += nsamples;
    sampn++;
    if (sampn % 1000 == 0) {
	console.log(sampcnt/sampn);
	sampcnt = sampn = 0;
    }
}

function mapConstants(node, path, parent) {
    if (node.isSymbolNode && node.name in ohmConstants)
	    return new math.expression.node.ConstantNode(ohmConstants[node.name]);
    return node;
}

function mapOhmutables(node, path, parent) {
    if (node.isFunctionNode && node.name in ohmutables) {
	node.args = node.args.map(function (arg) { return arg.transform(mapOhmutables) })
	return new math.expression.node.ConstantNode(node.eval());
    }
    if (node.isSymbolNode && node.name == 't')
	return new math.expression.node.ConstantNode(globaltime)
    return node;
}



function handler(msg) {
    const mparts = msg.split('=');
    const assignee = mparts.shift();
    const channel = parseInt(assignee.slice(8,9))
    var eqn = mparts.join('=')
    const parsed = math.parse(eqn).transform(mapConstants)
    const simpler = math.simplify(parsed).transform(mapOhmutables)
    streams[channel] = simpler.compile()
}

process.on('message', handler)

setInterval(writeOut, 0);


