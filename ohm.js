'use strict';

{
    const alsa = require('alsa')
    const math = require('mathjs')
    const ConstantNode = math.expression.node.ConstantNode
    const assign = Object.assign
    
    const o = {}
    o.alsa = alsa;
    o.math = math;
    
    const c = {
	device: "hw:0,0",
	sampleRate: 48000,
	sampleSigned: true,
	sampleBits: 32,
	sampleMax: 2147483647,
	sampleMin: -2147483647,
	samplePeriod: 512,
	sampleBuffer: 4096,
	vMax: 10,
	vMin: -10,
	v: 1,
	pi: Math.PI,
	tau: 2 * Math.PI
    }

    o.consts = assign(c, {
	vScale: (c.sampleMax-c.sampleMin)/(c.vMax-c.vMin),
	s: c.sampleRate,
	ms: c.sampleRate / 1000,
	mins: 60 * c.sampleRate,
	hz: c.tau / c.sampleRate,
	notes: {C:-9,Cs:-8,Db:-8,D:-7,Ds:-6,Eb:-6,E:-5,F:-4,Fs:-3,Gb:-3,G:-2,Gs:-1,Ab:-1,A:0,As:1,Bb:1,B:2}
    });

    assign(o.consts, o.consts.notes)
    assign(o, o.consts)

    const ohms = {}

    ohms.ohmo = class ohmo {
	constructor(vinitial) { this.val = vinitial }
	[Symbol.toPrimitive]() {
	    if (this.update) this.update();
	    return this.val;
	}
	propStr() { return `val=${this.val}` }
	toString() { return `${this.constructor.name}(${this.propStr()})` }
	static get isOhmo() { return true }
    }
    
    
    ohms.composite = class composite extends ohms.ohmo {
	constructor(fn,...args) {
	    super(0)
	    this.args = args
	    if (fn in mathOverrides)
		this.fn = mathOverrides[fn]
	    else {
		if (fn.isNode) fn = fn.name
		if (typeof fn == 'string') {
		    const sigs = math[fn].signatures
		    if ('number,number' in sigs) this.fn = sigs['number,number']
		    else if ('any,any' in sigs) this.fn = sigs['any,any']
		} else this.fn = fn
	    }
	    if (typeof this.fn != 'function')
		throw new Error('composite fn not a function: `${fn}->${this.fn}`')
	    this.fname = fn
	    this.update()
	}
	update() {
	    this.val = this.fn(...this.args.map(arg => +arg))
	}
	propStr() { return `fn=${this.fname} args=${this.args.map((arg)=>arg.toString()).join(',')}` }
    }

    ohms.triggered = class triggered extends ohms.ohmo {
	constructor(expr) {
	    super(-o.sampleRate*60*60);
	    this.expr = expr;
	    this.gate = 0;
	}
	update() {
	    if (this.gate) {
		if (+this.expr < 3*o.v) {
		    this.gate = 0
		}
	    } else {
		if (+this.expr >= 3*o.v) {
		    this.gate = 1
		    this.val = o.time.val
		}
	    }
	}
	propStr() { return `val=${this.val} expr=${this.expr}` }
    }

    ohms.genny = class genny extends ohms.ohmo {
	constructor(...args) {
	    super(0)
	    this.t = 0
	    this.init(...args)
	    this.val = this.next()
	}
	update() {
	    if (this.t < o.time.val) {
		this.t = o.time.val;
		this.val = this.next()
	    }
	}
	propStr() { return `t=${this.t} val=${this.val}` }
    }

    ohms.periodic = class periodic extends ohms.genny {
	init(freq) {
	    this.freq = freq
	    this.phase = -freq
	}
	next() {
	    this.phase += +this.freq;
	    return this.func()
	}
    }
    
    ohms.sinusoid = class sinusoid extends ohms.periodic {
	func() { return Math.sin(this.phase) }
    }

    ohms.sawtooth = class sawtooth extends ohms.periodic {
	func() { return (this.phase % o.tau)/o.pi-1 }
    } 

    o.ohms = ohms
    assign(o,o.ohms)

    o.time = new o.ohmo(0)
    
    o.mapConstants = (node, path, parent) => {
	if (node.isSymbolNode && node.name in o.consts)
	    return new ConstantNode(o.consts[node.name]);
	return node;
    }

    o.mapOhms = (node) => {
	if (node.isFunctionNode && node.name in ohms)
	    return new ohms[node.name](...node.args.map(arg => o.mapOhms(arg)))

	if (node.isSymbolNode && node.name == 't')
	    return o.time

	if (node.isConditionalNode)
	    return new o.composite((a,b,c)=>(+a)?(+b):(+c), o.mapOhms(node.condition),
				   o.mapOhms(node.trueExpr), o.mapOhms(node.falseExpr))
	
	if (node.isFunctionNode || node.isOperatorNode)
	    return new o.composite(node.fn,...node.args.map(arg=>o.mapOhms(arg)))

	if (node.isConstantNode)
	    return node.value
	    
	return node;
    }
   
    const mathExtras = { notehz: 'notehz(name,octave) = 440hz * (2^(1/12))^((octave-4)*12 + name)' }   
    for (let fname in mathExtras)
	mathExtras[fname] = math.parse(mathExtras[fname]).transform(o.mapConstants).eval()
    math.import(mathExtras)
    
    const mathOverrides = {
	mod: (a,b) => a % b,
	pow: Math.pow,
	smaller: (a,b) => a < b,
	smallerEq: (a,b) => a <= b,
	larger: (a,b) => a > b,
	largerEq: (a,b) => a >= b,
	unaryMinus: (a) => -a,
    }

    o.streams = [new o.ohmo(0),new o.ohmo(0)]
    
    o.handler = function(msg) {
	const mparts = msg.split('=');
	const assignee = mparts.shift();
	const channel = parseInt(assignee.slice(8,9))
	const eqn = mparts.join('=')
	const parsed = math.parse(eqn).transform(o.mapConstants)
	const simpler = math.simplify(parsed.transform((node, path, parent) => math.simplify(node)))
	//console.log('\n'+channel+': '+simpler.toString()+'\n')
	const composite = o.mapOhms(simpler)
	o.streams[channel] = composite
    }

    o.run = function() {
	o.pcm = alsa.Sound(o.device, o.sampleRate, o.samplePeriod, o.sampleBuffer);
	process.on('message', o.handler)
	process.on('disconnect', ()=>{ console.warn('\n\nchild process lost connection\n'); process.exit(0) })
	setInterval(() => {
	    const samples = o.pcm.writeBuffer()
	    const nsamples = samples.length
	    const vScale = o.vScale
	    let i = 0
	    while (i < nsamples) {
		samples[i++] = Math.round(vScale*o.streams[0]);
		samples[i++] = Math.round(vScale*o.streams[1]);
		o.time.val++
	    }
	    o.pcm.commit()
	},0);
    }
        
    module.exports = o
    if (require && require.main === module) {
	o.run()
	//o.handler('streams[0]=((((5v+(-1.8016603608984165v))*sinusoid((notehz(C,5)*2^(0+(-3.0715152057494293))))))+((((5v+((((5v+0+5v))*sinusoid((notehz(C,5)*2^(0+(-3.494547708133493))))))+(-5v)))/(10v)*0)))/2')
    }

    //require('repl').start().context.o=o
}


