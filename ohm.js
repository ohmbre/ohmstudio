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
	toString() { return o.symbolMap.has(this) ? `[${o.symbolMap.get(this)}]` : `${this.constructor.name}(${this.propStr()})` }
	static get isOhmo() { return true }
    }

    o.controls = {}
    
    ohms.control = class control extends ohms.ohmo {
	constructor(id) {
	    if (id in o.controls) {
		if (typeof(o.controls[id]) == 'number')
		    super(o.controls[id])
		else super(o.controls[id].val)//else throw new Error('Duplicate CV ID')
	    } else super(0)
	    this.id = id
	    o.controls[id] = this;
	}
	propStr() { return `id=${this.id}` }
    }

    ohms.genny = class genny extends ohms.ohmo {
	constructor(...args) {
	    super(null)
	    this.t = o.time.val
	    this.init(...args)
	    if (this.val == null)
		this.val = this.next()
	}
	update() {
	    if (this.t < o.time.val) {
		this.t = o.time.val;
		this.val = this.next()
	    }
	}
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

    ohms.triggered = class triggered extends ohms.genny {
	init(expr) {
	    this.expr = expr;
	    this.gate = 0;
	    if(+this.expr < 3*o.v) this.val = -o.sampleRate*60*60
	    else this.val = o.time.val;
	}
	next() {
	    if (this.gate) {
		if (+this.expr < 3*o.v) {
		    this.gate = 0
		}
	    } else {
		if (+this.expr >= 3*o.v) {
		    this.gate = 1
		    return o.time.val
		}
	    }
	    return this.val
	}
	propStr() { return `expr=${this.expr}` }
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
    
    ohms.sinusoid = class sinusoid extends ohms.periodic {
	func() { return Math.sin(this.phase) }
    }

    ohms.sawtooth = class sawtooth extends ohms.periodic {
	func() { return (this.phase % o.tau)/o.pi-1 }
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

    o.addMathFn = (name,fn) => {
	const type = {}
	type[name] = math.typed(name, {'number,number': fn})
	math.import(type)
	assign(o,type)
    }
    o.addMathFn('notehz', (name,octave) => 0.057595865 * 1.059463094**(12*(octave-4)+name))
    o.ohmrules=math.simplify.rules
    o.ohmrules.push('n/(n1/n2) -> (n*n2)/n1')
    o.ohmrules.push((node)=> {
	try {
	    return new ConstantNode(node.eval())
	} catch(err) {
	    return node
	}
    });
       
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
	    const dupes = o.dedupe(simpler)
	    const composite = o.mapOhms(simpler,dupes)
	    o.symbolMap = new Map()
	    for (let i=0; i < dupes.length; i++)
		o.symbolMap.set(dupes[i], String.fromCharCode(65+i))
	    o.streams[channel] = composite
	} else if (lhs.slice(0,8) == 'controls') {
	    let id = lhs.slice(9)
	    id = id.slice(0,id.indexOf(']'))
	    let val = parseFloat(rhs)
	    if (id in o.controls && typeof o.controls[id] != 'number') o.controls[id].val = val
	    else o.controls[id] = val
	}
    }

    o.run = function() {
	o.alsa = require('./alsa')
	o.pcm = o.alsa.Sound(o.device, o.sampleRate, o.samplePeriod, o.sampleBuffer);
	process.on('message', o.handler)
	process.on('disconnect', ()=>{ console.warn('\n\nchild process lost connection\n'); process.exit(0) })
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
    }
        
    module.exports = o
    if (require && require.main === module) {
	o.run()
    }

    //require('repl').start().context.o=o
}


