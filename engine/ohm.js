'use strict';
{
    const math = require('./math.min').create()
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
	scopeWindow: 512,
	scopeHistory: 512*256,
	scopeTrigChan: 0,
        vMax: 10,
        vMin: -10,
        v: 1,
        pi: Math.PI,
        tau: 2 * Math.PI
    }

    const ratioVoct = (ratio) => Math.log(ratio) / Math.log(2)
    o.consts = assign(c, {
        vScale: (c.sampleMax - c.sampleMin) / (c.vMax - c.vMin),
        s: c.sampleRate,
        ms: c.sampleRate / 1000,
        mins: 60 * c.sampleRate,
        hz: c.tau / c.sampleRate,
        notes: { C: -9, Cs: -8, Db: -8, D: -7, Ds: -6, Eb: -6, E: -5, F: -4, Fs: -3, Gb: -3, G: -2, Gs: -1, Ab: -1, A: 0, As: 1, Bb: 1, B: 2 },
        scales: {
            minor: [1, 9 / 8, 6 / 5, 27 / 20, 3 / 2, 8 / 5, 9 / 5].map(ratioVoct),
            locrian: [1, 16 / 15, 6 / 5, 4 / 3, 64 / 45, 8 / 5, 16 / 9].map(ratioVoct),
            major: [1, 9 / 8, 5 / 4, 4 / 3, 3 / 2, 5 / 3, 15 / 8].map(ratioVoct),
            dorian: [1, 10 / 9, 32 / 27, 4 / 3, 40 / 27, 5 / 3, 16 / 9].map(ratioVoct),
            phrygian: [1, 16 / 15, 6 / 5, 4 / 3, 3 / 2, 8 / 5, 9 / 5].map(ratioVoct),
            lydian: [1, 9 / 8, 5 / 4, 45 / 32, 3 / 2, 27 / 16, 15 / 8].map(ratioVoct),
            mixolydian: [1, 10 / 9, 5 / 4, 4 / 3, 3 / 2, 5 / 3, 16 / 9].map(ratioVoct),
            minorPentatonic: [1, 6 / 5, 27 / 20, 3 / 2, 9 / 5].map(ratioVoct),
            majorPentatonic: [1, 9 / 8, 5 / 4, 3 / 2, 5 / 3].map(ratioVoct),
            egyptian: [1, 10 / 9, 4 / 3, 40 / 27, 16 / 9].map(ratioVoct),
            minorBlues: [1, 6 / 5, 4 / 3, 8 / 5, 9 / 5].map(ratioVoct),
            majorBlues: [1, 10 / 9, 4 / 3, 3 / 2, 5 / 3].map(ratioVoct)
        }
    });

    assign(o.consts, o.consts.notes)
    assign(o.consts, o.consts.scales)
    assign(o, o.consts)

    const ohms = {}

    ohms.ohmo = class ohmo {
        getArgNames() {
            let argmatch = this.constructor.toString().match(/constructor\((.*)\)/)
            if (!argmatch) 
                argmatch = this.__proto__.__proto__.constructor.toString().match(/constructor\((.*)\)/)
            if (!argmatch) return []
            return argmatch[1].split(',').map(arg => arg.trim()).map(arg=>arg.slice(0,3)== '...' ? arg.slice(3) : arg)
                .filter(arg => Reflect.has(this, arg))
        }
        toString() {
            const args = this.getArgNames().map(arg => {
                if (Array.isArray(this[arg]))
                    return arg + '=' + this[arg].map(varg => varg.toString()).toString()
                return arg + '=' + this[arg].toString()
            }).join(' ')
            return `${this.constructor.name}(${args})`
        }
        toJSON() {
            const children = this.getArgNames().map(arg => {
                if (Array.isArray(this[arg]))
                    return { name: arg, children: this[arg].map(varg => varg.toJSON ? varg.toJSON() : varg.toString()) }
                return { name: arg, children: this[arg].toJSON ? this[arg].toJSON() : this[arg].toString() }
            })
            return { name: this.constructor.name, children: children }
        }
        static get isOhmo() { return true }
    }

    ohms.mutval = class mutval extends ohms.ohmo {
        constructor(vinitial) {
            super()
            this.val = vinitial
        }
        [Symbol.toPrimitive]() {
            return this.val;
        }
    }

    ohms.cached = class cached extends ohms.mutval {
        constructor(ohmo) {
            super(ohmo)
            this.t = o.time.val
        }
        [Symbol.toPrimitive]() {
            const curtime = o.time.val
            if (this.t != curtime || this.cachedval === undefined) {
                this.t = o.time.val
                this.cachedval = this.val[Symbol.toPrimitive]()
            }
            return this.cachedval
        }
    }

    ohms.timekeep = class timekeep extends ohms.mutval {
        toString() { return "t" }
    }

    ohms.capture = class capture extends ohms.mutval {
        constructor(channel, create = false) {
            if (!create) return o.instreams[channel]
            super(0)
            this.channel = channel
        }
    }

    o.controls = {}
    ohms.control = class control extends ohms.mutval {
        constructor(id) {
            if (id in o.controls) {
                if (typeof (o.controls[id]) == 'number')
                    super(o.controls[id])
                else super(o.controls[id].val)
            } else super(0)
            this.id = id
            o.controls[id] = this;
        }
    }

    ohms.composite = class composite extends ohms.ohmo {
        constructor(func, ...args) {
            super()
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
            this.func = func
            this[Symbol.toPrimitive] = this.fn.bind(this, ...args)
        }
    }

    ohms.randsample = class randsample extends ohms.ohmo {
        constructor(pool, nsamples, seed) {
            super()
            this.pool = pool
            this.lastnsamples = 0
            this.nsamples = nsamples
            this.lastseed = 279470274
            this.seed = (typeof seed == 'undefined') ? Math.floor(Math.random() * 279470273) : seed
            this.val = undefined
        }
        [Symbol.toPrimitive]() {
            let intseed = Math.round(this.seed)
            let intnsamples = Math.round(this.nsamples)
            if (intseed == this.lastseed && intnsamples == this.lastnsamples && this.val !== undefined) 
                return this.val
            this.lastseed = intseed
            this.lastnsamples = intnsamples
            const val = []
            while (val.length < intnsamples) {
                val.push(this.pool[intseed % this.pool.length])
                intseed = (intseed * 279470273) % 4294967291
            }
            return this.val = val
        }
    }

    ohms.noise = class noise extends ohms.ohmo {
	constructor(seed) {
	    super()
	    this.seed = seed
	    this.lastseed = 1
	}
	[Symbol.toPrimitive]() {
	    const seed = +this.seed
	    if (seed != this.lastseed) {
		this.lastseed = seed
		this.state = seed
	    }
	    this.state = (this.state * 279470273) % 4294967291
	    return this.state / 2147483645 - 1
	}
    }
	    

    ohms.sequence = class sequence extends ohms.ohmo {
        constructor(clock, values) {
            super()
            this.clock = clock
            this.values = values
            this.lastvalues = this.values[Symbol.toPrimitive]()
	    if (this.lastvalues === undefined)
		throw new Error('could not get primitive from: '+values)
            this.position = 0
            this.gate = false
        }
        [Symbol.toPrimitive]() {
            const clklvl = +this.clock
            if (!this.gate && clklvl >= 3) {
                this.lastvalues = this.values[Symbol.toPrimitive]()
                this.gate = true
                this.position = (this.position + 1) % this.lastvalues.length
            } else if (this.gate && clklvl <= 1)
                this.gate = false
            return this.lastvalues[this.position]
        }
    }

    ohms.ramps = class ramps extends ohms.ohmo {
        constructor(trig, initval, ...args) {
            super()
            this.trig = trig
            this.gate = false
            this.initval = initval
            this.timer = 0
            this.ramps = []
            this.args = [...args]
            this.val = initval
            this.running = false
        }
        [Symbol.toPrimitive]() {
            const siglvl = +this.trig
            if (!this.gate && siglvl >= 3) {
                this.gate = this.running = true
                this.timer = 0
                this.vstart = this.val
                this.rampsleft = [...this.args]
                const ramplist = this.rampsleft.splice(0, 3)
                this.target = ramplist[0]; this.len = ramplist[1]; this.shape = ramplist[2]
            } else if (this.gate && siglvl <= 1)
                this.gate = false
            if (!this.running) return this.val

            this.timer++
            let len = +this.len
            if (this.timer > len) {
                if (!this.rampsleft.length) {
                    this.running = false
                    return this.val
                }
                const ramplist = this.rampsleft.splice(0, 3)
                this.target = ramplist[0]; this.len = ramplist[1]; this.shape = ramplist[2]
                len = +this.len
                this.vstart = this.val
                this.timer = 1
            }
            const target = +this.target, shape = +this.shape
            if (len == 0) return this.val = target
            return this.val = target + (this.vstart - target) * (1 - this.timer / len) ** shape
        }
    }

    ohms.slew = class slew extends ohms.ohmo {
        constructor(signal, lag, shape) {
            super()
            this.tstart = o.time.val
            this.signal = signal
            this.lag = lag
            this.shape = shape
            this.val = 0
            this.target = 0
            
        }
        [Symbol.toPrimitive]() {
            const tdiff = o.time.val - this.tstart, lag = +this.lag, shape = +this.shape
            if (tdiff < lag)
                return this.val
            this.target = +this.signal
            this.tstart = o.time.val

            let delta = (this.val-this.target)*(shape+1)*(-1/lag)**3 + (this.val-this.target)*shape*(-1/this.lag)**2
            if (isNaN(delta)) delta = 0
            else delta = Math.min(Math.max(delta,-0.1),0.1)
            return this.val = this.val + delta
        }
    }

    ohms.clkdiv = class clkdiv extends ohms.ohmo {
	constructor(clock,div,shift) {
	    super()
	    this.clock = clock
	    this.div = div
	    this.shift = shift
	    this.count = 0
	    this.ingate = false
	}
	[Symbol.toPrimitive]() {
            const clklvl = +this.clock
            if (!this.ingate && clklvl >= 3) {
                this.ingate = true
                this.count++
            } else if (this.ingate && clklvl <= 1)
                this.ingate = false
	    if ((this.count-this.shift) % this.div == 0)
		return clklvl
            return 0
	}
    }
	    
    ohms.sinusoid = class sinusoid extends ohms.ohmo {
        constructor(freq) {
            super()
            this.freq = freq
            this.phase = 0
        }
        [Symbol.toPrimitive]() {
            this.phase += this.freq;
            return Math.sin(this.phase)
        }
    }

    ohms.sawtooth = class sawtooth extends ohms.ohmo {
        constructor(freq) {
            super()
            this.freq = freq
            this.phase = 0
        }
        [Symbol.toPrimitive]() {
            this.phase += this.freq;
            return (this.phase % o.tau) / o.pi - 1
        }
    }

    ohms.pwm = class pwm extends ohms.ohmo {
        constructor(freq, duty) {
            super()
            this.freq = freq
            this.phase = 0
            this.duty = duty
        }
        [Symbol.toPrimitive]() {
            this.phase += this.freq;
            return (((this.phase % o.tau) / o.tau) < this.duty) ? 1 : -1
        }
    }

    ohms.separator = class separator extends ohms.ohmo {
        constructor(...nodes) {
            super()
	    this.nodes = nodes
        }
        [Symbol.toPrimitive]() {
            throw new Exception("not supposed to execute this")
        }
    }
    
    o.ohms = ohms
    assign(o, o.ohms)

    o.clip = (min,v,max) => (v > max) ? max : ((v < min) ? min : v)
    
    o.addMathFn = (name, fn, sig = 'number,number') => {
        const type = {}
        const sigobj = {}; sigobj[sig] = fn
        type[name] = math.typed(name, sigobj)
        math.import(type)
        assign(o, type)
    }
    o.addMathFn('notehz', (name, octave) => 0.057595865 * 1.059463094 ** (12 * (octave - 4) + name))

    o.ohmrules = [...math.simplify.rules]

    o.ohmrules.push('n/(n1/n2) -> (n*n2)/n1')
    o.ohmrules.push('n^n1(n2/n3) -> (n2/n3)*n^n1')
    o.ohmrules.push('c/(c1*n) -> (c/c1)/n')
    o.ohmrules.push('c*(c1*n+c2*n1) -> (c*c1)*n+(c*c2)*n1')

    const mathOverrides = {
        mod: (a, b) => a % b,
        pow: Math.pow,
        smaller: (a, b) => a < b,
        smallerEq: (a, b) => a <= b,
        larger: (a, b) => a > b,
        largerEq: (a, b) => a >= b,
        unaryMinus: (a) => -a,
        add: (a, b) => a + b,
        multiply: (a, b) => a * b,
        divide: (a, b) => a / b
    }
    Object.assign(mathOverrides, Math)

    o.debug = (node, symbols) => {
        const fs = require('fs');
        let options = { parenthesis: 'auto', implicit: 'hide' }
        let html = `<html><head><script src="https://unpkg.com/mathjs@4.4.2/dist/math.min.js"></script><script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default" async/></script></head><body><table>${symbols.map(n => '<tr><td>$$' + n.symbol + ':=' + n.args[0].toTex(options) + '$$</td></tr>').join('\n')}<tr></tr>${node.args.map(n=> '<tr><td>$$ch'+ node.args.indexOf(n) + ':=' + n.toTex(options) + '$$</td></tr>').join('\n')}</table></body></html>`
        fs.writeFileSync('debug.html', html);
    }

    o.profile = () => {
        const fs = require('fs');
        let html = `<html><head><script src="https://unpkg.com/js-treeview@1.1.5/dist/treeview.min.js"></script><stylesheet src="https://unpkg.com/js-treeview@1.1.5/dist/treeview.min.css" type="text/css"></stylesheet></head><body><table><tr><td><div id='tree'></div></td></tr></table><script>var tree = new TreeView(${JSON.stringify(o.outstreams[0])}, 'tree')</script></body></html>`
        fs.writeFileSync('profile.html', html);
    }

    o.outstreams = new Array(5).fill(new o.ohmo(0))
    o.instreams = [new o.capture(0, true), new o.capture(1, true)]
    o.msgBacklog = []
    o.time = new o.timekeep(0)

    o.mapConstants = (node, path, parent) => {
        if (node.isSymbolNode && node.name in o.consts)
            return new ConstantNode(o.consts[node.name]);
        return node;
    }

    o.mapOhms = (node, symbols) => {
        if (node.isSymbolNode && node.name.slice(0, 1) == 'f') {
            const n = parseInt(node.name.slice(1))
            if (symbols[n].isNode)
                symbols[n] = o.mapOhms(symbols[n], symbols)
            return symbols[n]
        }
        
        if (node.isFunctionNode && node.name in ohms)
            return new ohms[node.name](...node.args.map(arg => o.mapOhms(arg, symbols)))

        if (node.isSymbolNode && node.name == 't')
            return o.time

        if (node.isConditionalNode)
            return new o.composite((a, b, c) => (+a) ? (+b) : (+c), o.mapOhms(node.condition, symbols),
				   o.mapOhms(node.trueExpr, symbols), o.mapOhms(node.falseExpr, symbols))

	if (node.isArrayNode)
	    return new o.mutval(node.items.map(it => o.mapOhms(it)))

        if (node.isFunctionNode || node.isOperatorNode)
            return new o.composite(node.fn, ...node.args.map(arg => o.mapOhms(arg, symbols)))

        if (node.isConstantNode)
            return node.value

        return node;
    }

    o.uniqify = (topnode) => {
        const seen = new Map()
        const symbolmap = new Map()
        topnode.traverse((node,path,parent) => { node.redirect = false })
        const queue = [topnode]
        while (queue.length) {
            const node = queue.shift()
            let nchildren = 0
            node.traverse((node, path, parent) => { nchildren++ })
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
            node.forEach((node, path, parent) => { queue.push(node) });
        }

        const symbolTransform = (node, path, parent) => {
            if (node.redirect) return new SymbolNode(node.redirect)
            return node
        }
        let symbols = [...symbolmap.entries()]
        symbols.sort((a, b) => parseInt(a[0].slice(1)) - parseInt(b[0].slice(1)))
        symbols = symbols.map(sym => {
            let clone = sym[1].clone()
            clone.redirect = false
            clone = new FunctionNode("cached",[clone.transform(symbolTransform)])
            clone.symbol = sym[0]
            return clone
        })
        let uniqified = topnode.transform(symbolTransform)
        
        return [uniqified, symbols]
    }


    o.handler = function (msg) {
        if (msg.cmd == 'set' && msg.key == 'streams') {
	    const simplified = msg.val.map(
		sval => math.simplify(
		    math.parse(sval)
			.transform(o.mapConstants)
			.transform((node, path, parent) => math.simplify(node, o.ohmrules)), o.ohmrules
		).transform((node, parent, path) => {
		    if (node.isOperatorNode)
			return new FunctionNode(node.fn, node.args)
		    return node
		}))
	    
            const combo = new FunctionNode('separator',simplified)
            let [uniqified, symbols] = o.uniqify(combo)           

            //o.debug(uniqified, symbols)
            const ohm = o.mapOhms(uniqified, symbols)

	    for (let n = 0; n < ohm.nodes.length; n++)
		o.outstreams[n] = ohm.nodes[n]
            o.symbols = symbols	    
        } else if (msg.cmd == 'set' && msg.key == 'controls') {
            let val = parseFloat(msg.val)
            if (msg.subkey in o.controls && typeof o.controls[msg.subkey] != 'number')
		o.controls[msg.subkey].val = val
            else o.controls[msg.subkey] = val
        } else if (msg.cmd == 'set' && msg.key == 'audioEnabled') {
	    if (msg.val == true && !o.audioEnabled) {
		o.audioEnabled = true
		o.runAudio()
	    } else if (msg.val == false && o.audioEnabled)
		o.audioEnabled = false
	} else if (msg.cmd == 'set' && msg.key == 'scopeEnabled') {
	    if (msg.val == true && !o.scopeEnabled) {
		o.scopeEnabled = true
		setTimeout(o.runScope,500)
	    } else if (msg.val == false && o.scopeEnabled)
		o.scopeEnabled = false
	}
    }

    o.audioEnabled = false
    o.scopeEnabled = false
                
    o.runScope = function() {
	const samples = new Int8Array(2*o.s)
	let bufpos = 0
	let hr = process.hrtime()
	const start = hr[0] + hr[1]/1e9
	let running = false
	let prevch1 = 0
	function loop() {
	    for (let i = 0; i < 512; i++) {
		const ch1 = +o.outstreams[0]
		const ch2 = +o.outstreams[1]
		const vtrig = +o.outstreams[2]
		const window = Math.min(Math.round(o.outstreams[3]), o.s) * 2
		if (!running && prevch1 < vtrig && ch1 >= vtrig) {
		    running = true
		    bufpos = 0
		} else if (running && bufpos > window) {
		    running = false
		    for (let client of o.clients)	
			client.send(new Int8Array(samples.buffer, 0, window),{binary: true})
		    bufpos = 0
		}
		if (running) {
		    samples[bufpos++] = o.clip(o.sampleMin,Math.round(o.vScale * ch1),o.sampleMax) >> 24
		    samples[bufpos++] = o.clip(o.sampleMin,Math.round(o.vScale * ch2),o.sampleMax) >> 24
		}
		o.time.val++
		prevch1 = ch1
	    }    
	    hr = process.hrtime()
	    const delay = Math.max(o.time.val / 48000 - (hr[0] + hr[1]/1e9 - start),0)
	    if (o.scopeEnabled)
		setTimeout(loop,delay)
	}
	if (o.scopeEnabled)
	    setTimeout(loop,0)
    }
    
    if (process.platform == 'linux')
	o.audio = (callback) => {
	    const alsa = require('./alsa')
	    if (!o.pcm)
		o.pcm = alsa.Sound(o.device, o.sampleRate, o.samplePeriod, o.sampleBuffer);
	    function loop() {
		const buffers = o.pcm.buffers()
		const outsamples = buffers.p
		const insamples = buffers.c
		callback(insamples,outsamples)
		o.pcm.commit();
		if (o.audioEnabled)
		    setTimeout(loop,0)
	    }
	    if (o.audioEnabled)
		setTimeout(loop,0)
	}
    else
	o.audio = (callback) => {
	    var coreAudio = require("node-core-audio");
	    var engine = coreAudio.createNewAudioEngine(
		{inputChannels: 2, outputChannels: 2, sampleRate: o.sampleRate, interleaved: true,
		 sampleFormat:coreAudio.sampleFormatInt32, framesPerBuffer: o.samplePeriod});
	    engine.addAudioCallback((insamples) => {
		const outsamples = new Array(insamples.length)
		callback(insamples,outsamples)
		if (!o.audioEnabled)
		    engine.processingCallbacks = []
		return outsamples
	    });    
	}

    o.runAudio = function() {
	o.audio((insamples,outsamples) => {
	    const nsamplesout = outsamples.length	    
	    const nsamplesin = insamples.length
	    const vScale = o.vScale
	    let icnt = 0, ocnt = 0, l = 0, r = 0, maxS = o.sampleMax, minS = o.sampleMin
	    
	    while (icnt < nsamplesin || ocnt < nsamplesout) {
		if (icnt < nsamplesin)
		    o.instreams[0].val = insamples[icnt++] / vScale;
		if (ocnt < nsamplesout) {
		    l = Math.round(vScale * o.outstreams[0]);
		    outsamples[ocnt++] = o.clip(minS,l,maxS)
		}
		if (icnt < nsamplesin) 
		    o.instreams[1].val = insamples[icnt++] / vScale
		if (ocnt < nsamplesout) {
		    r = Math.round(vScale * o.outstreams[1])
		    outsamples[ocnt++] = o.clip(minS,r,maxS)
		}		
		o.time.val++
	    }
	});
    }

    o.clients = []

    module.exports = o
    
    if (require && require.main === module) {
	o.port = parseInt(process.argv[process.argv.length-1])

	const WebSocket = require('ws');

	console.log('creating server on port', o.port)
	const wss = new WebSocket.Server({ port: o.port })
	
	wss.on('connection', (ws) => {
	    ws.on('message', function incoming(msg) {
		o.handler(JSON.parse(msg))
	    })
	    ws.on('close', function close() {
		console.error('\n\nchild process lost connection to ui\n')	
	    })
	    ws.binaryType = 'arraybuffer'
	    o.clients.push(ws)
	})	
    }
    
}
