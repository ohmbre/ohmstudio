'use strict';
{
    const math = require('mathjs').create()
    const ConstantNode = math.expression.node.ConstantNode
    const FunctionNode = math.expression.node.FunctionNode
    const OperatorNode = math.expression.node.OperatorNode
    const ConditionalNode = math.expression.node.ConditionalNode
    const SymbolNode = math.expression.node.SymbolNode

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
	    this.update();
            return this.val;
        }
	update() {}
	getArgNames() {
	    const constructor = this.constructor.toString()
	    let argmatch = constructor.match(/constructor\((.*)\)/)
	    if (!argmatch) argmatch = constructor.match(/init\((.*)\)/)
	    if (!argmatch) argmatch = this.__proto__.__proto__.constructor.toString().match(/init\((.*)\)/)
	    return argmatch[1].split(',').map(arg=>arg.slice(0,3) == '...' ? arg.slice(3) : arg).filter(arg=> Reflect.has(this,arg))
	}
        toString() {
	    const args = this.getArgNames().map(arg=> {
		if (Array.isArray(this[arg]))
		    return arg+'='+this[arg].map(varg=>varg.toString()).toString()
		return arg+'='+this[arg].toString()
	    }).join(' ')
	    return `${this.constructor.name}(${args})`
	}
	toJSON() {
	    const children = this.getArgNames().map(arg=> {
		if (Array.isArray(this[arg]))
		    return {name: arg, children: this[arg].map(varg=>varg.toJSON? varg.toJSON() : varg.toString())}
		return {name: arg, children: this[arg].toJSON? this[arg].toJSON() : this[arg].toString()}
	    })
	    return {name: this.constructor.name, children: children}
	}
        static get isOhmo() { return true }
    }

    ohms.timekeep = class timekeep extends ohms.ohmo {
        [Symbol.toPrimitive]() {
	    return this.val
	}
	toString() {
	    return "t"
	}
    }

    ohms.capture = class capture extends ohms.ohmo {
	constructor(channel,create=false) {
	    if(!create) return o.instreams[channel]
	    super(0)
	    this.channel = channel
	}
        [Symbol.toPrimitive]() {
	    return this.val
	}
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
	    const curtime = o.time.val;
            if (this.t != curtime) {
                this.t = curtime;
                this.val = this.next()
            }
        }
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
        [Symbol.toPrimitive]() {
            return this.val;
        }	
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
            this.phase += this.freq;
            return this.func()
        }
    }

    ohms.ramps = class ramps extends ohms.genny {
        init(trig, initval, ...args) {
            this.trig = trig
	    this.gate = false
	    this.initval = initval
	    this.timer = 0
	    this.ramps = []
	    this.args = [...args]
            this.val = initval
	    this.running = false
        }
        next() {
	    const siglvl = +this.trig
	    if (!this.gate && siglvl >= 3) {
		this.gate = this.running = true
		this.timer = 0
		this.vstart = this.val
		this.rampsleft = [...this.args]
		const ramplist = this.rampsleft.splice(0,3)
		this.target = ramplist[0]; this.len = ramplist[1]; this.shape = ramplist[2]
	    } else if (this.gate && siglvl <= 1)
		this.gate = false
	    if (!this.running) return this.val

	    this.timer++
            let len = +this.len
            if (this.timer >= len) {
		if (!this.rampsleft.length) {
		    this.running = false
		    return this.val
		}
		const ramplist = this.rampsleft.splice(0,3)
		this.target = ramplist[0]; this.len = ramplist[1]; this.shape = ramplist[2]
		len = +this.len
                this.vstart = this.val
		this.timer = 1
            }
	    const target = +this.target, shape = +this.shape
	    if (len == 0) return target
	    return target + (this.vstart - target) * (1-this.timer/len)**shape
        }
    }

    ohms.slew = class slew extends ohms.genny {
        init(signal,lag,shape) {
            this.signal = signal
            this.lag = lag
            this.shape = shape
            this.val = +this.signal
            this.target = this.val
            this.tstart = this.t
        }
        next() {
            const tdiff = this.t - this.tstart, lag = +this.lag, shape = +this.shape
            if (tdiff < lag)
            return this.val
            this.target = +this.signal
            this.tstart = this.t
            return this.val + (this.val - this.target) * (shape + 1) * (-1/this.lag)**3 +
            (this.val - this.target) * shape * (-1/this.lag)**2
        }
    }

    ohms.composite = class composite extends ohms.genny {
        init(func,...args) {
            this.args = args
            if (func in mathOverrides)
		this.fn = mathOverrides[func]
            else {
                if (func.isNode) func = func.name
                if (typeof func == 'string') {
                    const sigs = math[func].signatures
                    if ('number,number' in sigs) this.fn = sigs['number,number']
                    else if ('any,any' in sigs) this.fn = sigs['any,any']
                    else if ('number' in sigs) this.fn = sigs['number']
                    else if ('any' in sigs) this.fn = sigs['any']
                } else this.fn = func
            }
            if (typeof this.fn != 'function')
            throw new Error(`composite fn not a function: ${fn}->${this.fn}`)

        }
	[Symbol.toPrimitive]() {
            return this.fn.apply(null,this.args)
	}
        next() {}
	update() {}
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
    }


    o.ohms = ohms
    assign(o,o.ohms)

    o.time = new o.timekeep(0)

    o.mapConstants = (node, path, parent) => {
        if (node.isSymbolNode && node.name in o.consts)
        return new ConstantNode(o.consts[node.name]);
        return node;
    }

    o.mapOhms = (node,symbols) => {
        if (node.isSymbolNode && node.name.slice(0,1) == 'f') {
            const n = parseInt(node.name.slice(1))
            if (symbols[n].isNode)
            symbols[n] = o.mapOhms(symbols[n],symbols)
            return symbols[n]
        }

        if (node.isFunctionNode && node.name in ohms)
        return new ohms[node.name](...node.args.map(arg => o.mapOhms(arg,symbols)))

        if (node.isSymbolNode && node.name == 't')
        return o.time

        if (node.isConditionalNode)
        return new o.composite((a,b,c)=>(+a)?(+b):(+c), o.mapOhms(node.condition,symbols),
        o.mapOhms(node.trueExpr,symbols), o.mapOhms(node.falseExpr,symbols))

        if (node.isFunctionNode || node.isOperatorNode)
        return new o.composite(node.fn,...node.args.map(arg=>o.mapOhms(arg,symbols)))

        if (node.isConstantNode)
        return node.value

        return node;
    }

    o.uniqify = (topnode) => {
        const seen = new Map()
        const symbolmap = new Map()
        const queue = [topnode]
        while (queue.length) {
            const node = queue.shift()
            let nchildren = 0
            node.traverse((node,path,parent)=>{ nchildren++ })
            if (nchildren < 2) continue
            node.rep = node.toString()
            const other = seen.get(node.rep)
            if (other) {
                if (other.redirect)
                    node.redirect = other.redirect
		else {
                    const symname = `f${symbolmap.size}`
                    other.redirect = symname
                    node.redirect = symname
                    symbolmap.set(symname, other)
		}
                continue
            }
            seen.set(node.rep, node)
            node.forEach((node,path,parent)=> { queue.push(node) });
        }
        const symbolTransform = (node,path,parent) => {
            if (node.redirect) return new SymbolNode(node.redirect)
            return node
        }
        let symbols = [...symbolmap.entries()]
        symbols.sort((a,b)=>parseInt(a[0].slice(1))-parseInt(b[0].slice(1)))
        symbols = symbols.map(sym=> {
            let clone = sym[1].clone()
            clone.redirect = false
            clone = clone.transform(symbolTransform)
            clone.symbol=sym[0]
            return clone
        })
        let uniqified = topnode.transform(symbolTransform)
        return [uniqified,symbols]
    }

    o.addMathFn = (name, fn, sig='number,number') => {
	const type = {}
	const sigobj = {}; sigobj[sig] = fn
	type[name] = math.typed(name, sigobj)
	math.import(type)
	assign(o,type)
    }
    o.addMathFn('notehz', (name,octave) => 0.057595865 * 1.059463094**(12*(octave-4)+name))
    
    o.ohmrules=[...math.simplify.rules]
    
    o.ohmrules.push('n/(n1/n2) -> (n*n2)/n1')
    o.ohmrules.push('n^n1(n2/n3) -> (n2/n3)*n^n1')
    o.ohmrules.push('c/(c1*n) -> (c/c1)/n')
    o.ohmrules.push('c*(c1*n+c2*n1) -> (c*c1)*n+(c*c2)*n1')
    
    const mathOverrides = {
	mod: (a,b) => a % b,
	pow: Math.pow,
	smaller: (a,b) => a < b,
	smallerEq: (a,b) => a <= b,
	larger: (a,b) => a > b,
	largerEq: (a,b) => a >= b,
	unaryMinus: (a) => -a,
	add: (a,b) => a+b,
	multiply: (a,b) => a*b,
	divide: (a,b) => a/b
    }
    Object.assign(mathOverrides,Math)

    o.debug = (node,symbols)=> {
	const fs = require('fs');
	let options = {parenthesis: 'auto', implicit: 'hide'}
	let html = `<html><head><script src="https://unpkg.com/mathjs@4.4.2/dist/math.min.js"></script><script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default" async/></script></head><body><table>${symbols.map(n=>'<tr><td>$$'+n.symbol + ':=' + n.toTex(options)+'$$</td></tr>').join('\n')}<tr><td>$$ ${node.toTex(options)} $$</td></tr></table></body></html>`
	fs.writeFileSync('debug.html', html);
    }

    o.profile = () => {
	const fs = require('fs');
	let html = `<html><head><script src="https://unpkg.com/js-treeview@1.1.5/dist/treeview.min.js"></script><stylesheet src="https://unpkg.com/js-treeview@1.1.5/dist/treeview.min.css" type="text/css"></stylesheet></head><body><table><tr><td><div id='tree'></div></td></tr></table><script>var tree = new TreeView(${JSON.stringify(o.outstreams[0])}, 'tree')</script></body></html>`
    	fs.writeFileSync('profile.html', html);
    }
    
    o.outstreams = [new o.ohmo(0),new o.ohmo(0)]
    o.instreams = [new o.capture(0,true), new o.capture(1,true)]
    o.symbols = [[],[]]
    
    o.handler = function(msg) {
	const mparts = msg.split('=');
	const lhs = mparts.shift();
	const rhs = mparts.join('=')
	if (lhs.slice(0,7) == 'streams') {
            const channel = parseInt(lhs.slice(8,9))
            const parsed = math.parse(rhs).transform(o.mapConstants)
            const simpler = math.simplify(parsed.transform((node, path, parent) => math.simplify(node,o.ohmrules)),o.ohmrules).transform((node,parent,path)=> {
		if (node.isOperatorNode)
		    return new FunctionNode(node.fn, node.args)
		return node
            });
            let [uniqified,symbols] = o.uniqify(simpler)
            o.debug(uniqified,symbols)
            o.outstreams[channel] = o.mapOhms(uniqified,symbols)
            o.symbols[channel] = symbols
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
		const buffers = o.pcm.buffers()
		const outsamples = buffers['p']
		const insamples = buffers['c']
		const nsamplesout = outsamples.length
		const nsamplesin = insamples.length
		const vScale = o.vScale
		let i=0,l=0,r=0,maxS=o.sampleMax,minS=o.sampleMin
		let nsamples = Math.max(nsamplesout,nsamplesin)
		while (i < nsamples) {
		    if (i < nsamplesin)
			o.instreams[0].val = insamples[i] / vScale
                    if (i < nsamplesout) {
			l = Math.round(vScale*o.outstreams[0])
			outsamples[i] = l > maxS ? maxS : (l < minS ? minS : l)
		    }
		    i++

		    if (i < nsamplesin)
			o.instreams[1].val = insamples[i] / vScale
                    if (i < nsamplesout) {
			r = Math.round(vScale*o.outstreams[1])
			outsamples[i] = r > maxS ? maxS : (r < minS ? minS : r)
		    }
		    i++
		    
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
                    l = Math.round(vScale*o.outstreams[0])
                    samples.writeInt32LE(l > maxS ? maxS : (l < minS ? minS : l), offset)
                    offset += sampleBytes
                    r = Math.round(vScale*o.outstreams[1])
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
	//for (let msg of require('./testdata'))
	//    o.handler(msg)
    }

}
