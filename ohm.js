'use strict';
{
    const math = require('mathjs').create()//{predictable: true, number: 'number'})
    const ConstantNode = math.expression.node.ConstantNode
    const assign = Object.assign
    const o = {}
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

    const ratioVoct = (ratio) => Math.log(ratio)/Math.log(2)
    o.consts = assign(c, {
	vScale: (c.sampleMax-c.sampleMin)/(c.vMax-c.vMin),
	s: c.sampleRate,
	ms: c.sampleRate / 1000,
	mins: 60 * c.sampleRate,
	hz: c.tau / c.sampleRate,
	notes: {C:-9,Cs:-8,Db:-8,D:-7,Ds:-6,Eb:-6,E:-5,F:-4,Fs:-3,Gb:-3,G:-2,Gs:-1,Ab:-1,A:0,As:1,Bb:1,B:2},
	scales: {
	    minor: [1,9/8,6/5,27/20,3/2,8/5,9/5].map(ratioVoct),
	    locrian: [1,16/15,6/5,4/3,64/45,8/5,16/9].map(ratioVoct),
	    major: [1,9/8,5/4,4/3,3/2,5/3,15/8].map(ratioVoct),
	    dorian: [1,10/9,32/27,4/3,40/27,5/3,16/9].map(ratioVoct),
	    phrygian: [1,16/15,6/5,4/3,3/2,8/5,9/5].map(ratioVoct),
	    lydian: [1,9/8,5/4,45/32,3/2,27/16,15/8].map(ratioVoct),
	    mixolydian: [1,10/9,5/4,4/3,3/2,5/3,16/9].map(ratioVoct),
	    minorPentatonic: [1,6/5,27/20,3/2,9/5].map(ratioVoct),
	    majorPentatonic: [1,9/8,5/4,3/2,5/3].map(ratioVoct),
	    egyptian: [1,10/9,4/3,40/27,16/9].map(ratioVoct),
	    minorBlues: [1,6/5,4/3,8/5,9/5].map(ratioVoct),
	    majorBlues: [1,10/9,4/3,3/2,5/3].map(ratioVoct)
	}
    });

    assign(o.consts, o.consts.notes)
    assign(o.consts, o.consts.scales)
    assign(o, o.consts)

    const ohms = {}

    ohms.ohmo = class ohmo {
	constructor(vinitial) { this.val = vinitial }
	[Symbol.toPrimitive]() {
	    if (this.update) this.update();
	    return this.val;
	}
	propStr() { return `val=${this.val}` }
	toString() { return o.symbolMap.has(this) ? `[${o.symbolMap.get(this)}]` : `${this.constructor.name}(${this.propStr()})` }
	static get isOhmo() { return true }
    }

    ohms.randsample = class randsample extends ohms.ohmo {
	constructor(pool, nsamples, seed) {
	    super(null);
	    this.pool = pool
	    this.lastnsamples = 0
	    this.nsamples = nsamples
	    this.lastseed = 279470274
	    this.seed = (typeof seed == 'undefined') ? Math.floor(Math.random()*279470273) : seed
	}
	update() {
	    let intseed = Math.round(this.seed)
	    let intnsamples = Math.round(this.nsamples)
	    if (intseed == this.lastseed && intnsamples == this.lastnsamples) return 
	    this.lastseed = intseed
	    this.lastnsamples = intnsamples
	    this.val = []
		while (this.val.length < intnsamples) {
		this.val.push(this.pool[intseed % this.pool.length])
		intseed = (intseed * 279470273) % 4294967291
	    }
	}
	propstr() { return `nsamples=${this.nsamples} seed=${this.seed}` }
    }
	
    ohms.genny = class genny extends ohms.ohmo {
	constructor(...args) {
	    super(null)
	    this.time = o.time
	    this.init(...args)
	    this.t = this.time.val
	    if (this.val == null)
		this.val = this.next()
	}
	update() {
	    if (this.t != this.time) {
		this.t = this.time.val;
		this.val = this.next()
	    }
	}
    }
	
    o.controls = {}
	ohms.control = class control extends ohms.ohmo {
	constructor(id) {
	    if (id in o.controls) {
		if (typeof(o.controls[id]) == 'number')
		    super(o.controls[id])
		else super(o.controls[id].val)
	    } else super(0)
	    this.id = id
	    o.controls[id] = this;
	}
	propStr() { return `id=${this.id}` }
    }

    ohms.sequence = class sequence extends ohms.genny {
	init(clock,values) {
	    this.clock = clock
	    this.values = values
	    this.lastvalues = values[Symbol.toPrimitive]()
	    this.position = 0
	    this.gate = false
	    this.val = this.lastvalues[this.position]
	}
	next() {
	    const clklvl = +this.clock
	    if (!this.gate && clklvl >= 3) {
		this.lastvalues = this.values[Symbol.toPrimitive]()
		this.gate = true
		this.position = (this.position+1) % this.lastvalues.length
	    } else if (this.gate && clklvl <= 1)
		this.gate = false
	    return this.lastvalues[this.position]
	}
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
	propStr() {
	    return `freq=${this.freq.toString()}`
	}
    }
    
    ohms.timer = class timer extends ohms.genny {
	init(signal,direction) {
	    this.signal = signal
	    this.val = 0
	    this.gate = false
	}
	next() {
	    const siglvl = +this.signal
	    if (!this.gate && siglvl >= 3) {
		this.gate = true
		return 1
	    } else if (this.gate && siglvl <= 1)
		this.gate = false
	    if (this.val == 0) return this.val
	    return this.val + 1
	}
	propStr() { return `signal=${this.signal} direction=${this.direction}` }
    }
    
    ohms.ramps = class ramps extends ohms.genny {
	init(time, initval, ...args) {
	    this.time = time
	    this.args = [...args]
	    this.seq = [...args]
	    this.target = this.val = this.vstart = initval
	    this.tstart = 0
	    this.tlen = 1
	    this.shape = 1
	    this.slope = 0
	}
	nextSeq() {
	    if (this.seq.length < 3) return this.val
	    const ramp = this.seq.splice(0,3)	    
	    this.target = ramp[0]; this.tlen = ramp[1]; this.shape = ramp[2]
	    this.slope = 0
	    return false
	}
	next() {
	    const tlen = +this.tlen, t = +this.t
	    let ret = 0
	    if (t >= (this.tstart + tlen)) {
		this.tstart += tlen
		this.vstart = this.val
		if (ret = this.nextSeq()) return ret
	    } else if (t < this.tstart) {
		this.tstart = 1
		this.vstart = this.val
		this.seq = [...this.args]
		if (ret = this.nextSeq()) return ret
	    }
	    return this.target + (this.vstart - this.target) * (1-(t-this.tstart)/tlen)**this.shape
	}
	propStr() { return `time=${this.time}` } 
    }

    ohms.slew = class slew extends ohms.genny {
	init(signal,lag,shape) {
	    this.signal = signal
	    this.lag = lag
	    this.shape = shape
	    this.val = +this.signal
	    this.target = this.val
	    this.tstart = this.time.val
	}
	next() {
	    const tdiff = this.t - this.tstart
	    if (tdiff < this.lag)
		return this.val
	    this.target = +this.signal
	    this.tstart = this.t
	    return this.val + (this.val - this.target) * (this.shape + 1) * (-1/this.lag)**3 +
    		(this.val - this.target) * this.shape * (-1/this.lag)**2
	}
	propStr() { return `signal=${this.signal.toString()}` }
    }
	    
    ohms.composite = class composite extends ohms.genny {
	init(fn,...args) {
	    this.args = args
	    if (fn in mathOverrides)
		this.fn = mathOverrides[fn]
	    else {
		if (fn.isNode) fn = fn.name
		if (typeof fn == 'string') {
		    const sigs = math[fn].signatures
		    if ('number,number' in sigs) this.fn = sigs['number,number']
		    else if ('any,any' in sigs) this.fn = sigs['any,any']
		    else if ('number' in sigs) this.fn = sigs['number']
		    else if ('any' in sigs) this.fn = sigs['any']
		} else this.fn = fn
	    }
	    if (typeof this.fn != 'function')
		throw new Error(`composite fn not a function: ${fn}->${this.fn}`)
	    this.fname = fn
	}
	next() {
	    return this.fn(...this.args.map(arg => +arg))
	}
	propStr() { return `fn=${this.fname} args=${this.args.map((arg)=>arg.toString()).join(',')}` }
    }
    
    ohms.sinusoid = class sinusoid extends ohms.periodic {
	func() { return Math.sin(this.phase) }
    }

    ohms.sawtooth = class sawtooth extends ohms.periodic {
	func() { return (this.phase % o.tau)/o.pi-1 }
    } 

    ohms.pwm = class pwm extends ohms.periodic {
	init(freq,duty) {
	    super.init(freq)
	    this.duty = duty
	}
	func() { return (((this.phase % o.tau)/o.tau) < this.duty) ? 1 : 0 }
	propStr() { return super.propStr() + ` duty=${this.duty}` }
    }

    
    o.ohms = ohms
    assign(o,o.ohms)
    
    o.time = new o.ohmo(0)
    o.time.toString=()=>'t'
    
    o.mapConstants = (node, path, parent) => {
	if (node.isSymbolNode && node.name in o.consts)
	    return new ConstantNode(o.consts[node.name]);
	return node;
    }

    o.mapOhms = (node,dupes) => {
	if (typeof node.redirect != 'undefined')
	    node = dupes[node.redirect]

	if (node.isFunctionNode && node.name in ohms)
	    return new ohms[node.name](...node.args.map(arg => o.mapOhms(arg,dupes)))

	if (node.isSymbolNode && node.name == 't')
	    return o.time

	if (node.isConditionalNode)
	    return new o.composite((a,b,c)=>(+a)?(+b):(+c), o.mapOhms(node.condition,dupes),
				   o.mapOhms(node.trueExpr,dupes), o.mapOhms(node.falseExpr,dupes))
	
	if (node.isFunctionNode || node.isOperatorNode)
	    return new o.composite(node.fn,...node.args.map(arg=>o.mapOhms(arg,dupes)))

	if (node.isConstantNode)
	    return node.value
	    
	return node;
    }

    o.dedupe = (node) => {
	const recurse = (node,index) => {
	    node.nchildren = 0
	    node.forEach((subnode,path,parent)=> {
		parent.nchildren++;
		recurse(subnode,index);
		parent.nchildren += subnode.nchildren;
	    });
	    if (node.nchildren > 0) {
		node.rep = node.toString()
		const inodes = index.get(node.rep)
		if (!inodes) index.set(node.rep,[node])
		else inodes.push(node)
	    }
	}
	const index = new Map()
	recurse(node,index)
	const dupes = []
	for (var [rep, nodes] of index)
	    if (nodes.length > 1) {
		for (let copy of nodes)
		    copy.redirect = dupes.length
		const clone = nodes[0].clone()
		clone.redirect = undefined;
		dupes.push(clone)
	    }
	for (let i=0; i < dupes.length; i++) 
	    dupes[i] = o.mapOhms(dupes[i],dupes);
	return dupes
    }

    o.addMathFn = (name, fn, sig='number,number') => {
	const type = {}
	const sigobj = {}; sigobj[sig] = fn
	type[name] = math.typed(name, sigobj)
	math.import(type)
	assign(o,type)
    }
    o.addMathFn('notehz', (name,octave) => 0.057595865 * 1.059463094**(12*(octave-4)+name))
    
	o.ohmrules=[...math.simplify.rules].filter((rule)=> rule.name != 'simplifyConstant')
    o.ohmrules.splice(0,0,(node)=> {
	try {
	    return new ConstantNode(node.eval())
	} catch(err) {
	    return node
	}
    });
    //o.ohmrules.push('n/(n1/n2) -> (n*n2)/n1')
    //o.ohmrules.push('n^n1(n2/n3)-> (n2/n3)*n^n1')
    //o.ohmrules.splice(17,1)

    const mathOverrides = {
	mod: (a,b) => a % b,
	pow: Math.pow,
	smaller: (a,b) => a < b,
	smallerEq: (a,b) => a <= b,
	larger: (a,b) => a > b,
	largerEq: (a,b) => a >= b,
	unaryMinus: (a) => -a,
    }
    Object.assign(mathOverrides,Math)
    
    o.streams = [new o.ohmo(0),new o.ohmo(0)]
    
    o.handler = function(msg) {
	const mparts = msg.split('=');
	const lhs = mparts.shift();
	const rhs = mparts.join('=')
	if (lhs.slice(0,7) == 'streams') {
	    const channel = parseInt(lhs.slice(8,9))
	    const parsed = math.parse(rhs).transform(o.mapConstants)
	    const simpler = math.simplify(parsed.transform((node, path, parent) => math.simplify(node,o.ohmrules)),o.ohmrules)
	    //console.log(simpler.toString())
	    const dupes = o.dedupe(simpler)
	    const composite = o.mapOhms(simpler,dupes)
	    o.symbolMap = new Map()
	    for (let i=0; i < dupes.length; i++)
		o.symbolMap.set(dupes[i], String.fromCharCode(65+i))
	    o.streams[channel] = composite
	    //console.log(composite.toString())
	} else if (lhs.slice(0,8) == 'controls') {
	    let id = lhs.slice(9)
	    id = id.slice(0,id.indexOf(']'))
	    let val = parseFloat(rhs)
	    if (id in o.controls && typeof o.controls[id] != 'number') o.controls[id].val = val
	    else o.controls[id] = val
	}
    }

    o.run = function() {

	process.on('message', o.handler)
	process.on('disconnect', ()=>{ console.warn('\n\nchild process lost connection\n'); process.exit(0) })
	try {
	    console.log('trying alsa');
	    o.alsa = require('./alsa')
	    o.pcm = o.alsa.Sound(o.device, o.sampleRate, o.samplePeriod, o.sampleBuffer);
	    setInterval(() => {
		    const samples = o.pcm.writeBuffer()
		    const nsamples = samples.length
		    const vScale = o.vScale
		    let i=0,l=0,r=0,maxS=o.sampleMax,minS=o.sampleMin
		    while (i < nsamples) {
			l = Math.round(vScale*o.streams[0])
			samples[i++] = l > maxS ? maxS : (l < minS ? minS : l)
			r = Math.round(vScale*o.streams[1])
			samples[i++] = r > maxS ? maxS : (r < minS ? minS : r)
			o.time.val++
		    }
		    o.pcm.commit()	
		},0);
	} catch (err) {
	    console.log('trying speaker...')
	    const Speaker = require('speaker');
	    const bufferAlloc = require('buffer-alloc')
	    const Readable = require('stream').Readable
	    const sampleBytes = o.sampleBits/8
	    function read(n) {
		const samples = bufferAlloc(n)
		const vScale = o.vScale
		let offset = 0, l = 0, r = 0, maxS=o.sampleMax, minS=o.sampleMin
		while (offset < n) {
		    l = Math.round(vScale*o.streams[0])
		    samples.writeInt32LE(l > maxS ? maxS : (l < minS ? minS : l), offset)
		    offset += sampleBytes
		    r = Math.round(vScale*o.streams[1])
		    samples.writeInt32LE(r > maxS ? maxS : (r < minS ? minS : r), offset)
		    offset += sampleBytes
		    o.time.val++
		}
		this.push(samples)
		this.samplesGenerated += n/(sampleBytes*2)
	    }
	    const samples = new Readable()
	    samples.bitDepth = o.sampleBits
	    samples.channels = 2
	    samples.sampleRate = o.sampleRate
	    samples.samplesGenerated = 0
	    samples._read = read
	    samples.pipe(new Speaker({channels: 2, bitDepth: 32, sampleRate: 48000, signed: true, samplesPerFrame: o.samplePeriod}))
	}
    }
       
	module.exports = o
	if (require && require.main === module) {
	    o.run()
	}

    //require('repl').start().context.o=o
}


