const samplePeriod = 512
const sampleRate = 48000

const pi = Math.PI
const tau = 2 * pi

const mathOps = {
    mod: (a, b) => a % b,
    pow: Math.pow,
    smaller: (a, b) => a < b,
    smallerEq: (a, b) => a <= b,
    larger: (a, b) => a > b,
    largerEq: (a, b) => a >= b,
    unaryMinus: (a) => -a,
    add: (a, b) => a + b,
    multiply: (a, b) => a * b,
    divide: (a, b) => a / b,
    max: (a,b) => {
	const ap = +a
	const bp = +b 
	return ap > bp ? ap : bp
    }
}

class ohm {
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
    static get isOhm() { return true }
}

class mutval extends ohm {
    constructor(vinitial) {
        super()
        this.val = vinitial
    }
    [Symbol.toPrimitive]() {
        return this.val;
    }
}

class cached extends mutval {
    constructor(ohmo) {
        super(ohmo)
        this.t = time.val
    }
    [Symbol.toPrimitive]() {
        const curtime = time.val
        if (this.t != curtime || this.cachedval === undefined) {
            this.t = time.val
            this.cachedval = this.val[Symbol.toPrimitive]()
        }
        return this.cachedval
    }
}

class timekeep extends mutval {
    toString() { return "t" }
}

class capture extends mutval {
    constructor(channel, create = false) {
        if (!create) return streams.in[channel]
    super(0)
        this.channel = channel
    }
}

class control extends mutval {
    constructor(id) {
        if (id in controls) {
            if (typeof (controls[id]) == 'number')
                super(controls[id])
            else super(controls[id].val)
        } else super(0)
        this.id = id
        controls[id] = this;
    }
}

class composite extends ohm {
    constructor(func, ...args) {
        super()
        this.args = args
    this.func = func
    if (typeof func == 'function')
        this.fn = func
    else if (func in mathOps)
        this.fn = mathOps[func]
    else
            throw new Error(`composite func not a function: ${func}`)

        this[Symbol.toPrimitive] = this.fn.bind(this, ...args)
    }
}

class randsample extends ohm {
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
        if (intseed == this.lastseed && intnsamples == this.lastnsamples
        && this.val !== undefined) return this.val
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

class noise extends ohm {
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


class sequence extends ohm {
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

class ramps extends ohm {
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

class slew extends ohm {
    constructor(signal, lag, shape) {
        super()
        this.tstart = time.val
        this.signal = signal
        this.lag = lag
        this.shape = shape
        this.val = 0
        this.target = 0
    }
    [Symbol.toPrimitive]() {
        const tdiff = time.val - this.tstart, lag = +this.lag, shape = +this.shape
        if (tdiff < lag)
            return this.val
        this.target = +this.signal
        this.tstart = time.val

        let delta = (this.val-this.target)*(shape+1)*(-1/lag)**3 + (this.val-this.target)*shape*(-1/this.lag)**2
        if (isNaN(delta)) delta = 0
        else delta = Math.min(Math.max(delta,-0.1),0.1)
        return this.val = this.val + delta
    }
}

class clkdiv extends ohm {
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

class sinusoid extends ohm {
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

class sawtooth extends ohm {
    constructor(freq) {
        super()
        this.freq = freq
        this.phase = 0
    }
    [Symbol.toPrimitive]() {
        this.phase += this.freq;
        return (this.phase % tau) / pi - 1
    }
}

class pwm extends ohm {
    constructor(freq, duty) {
        super()
        this.freq = freq
        this.phase = 0
        this.duty = duty
    }
    [Symbol.toPrimitive]() {
        this.phase += this.freq;
        return (((this.phase % tau) / tau) < this.duty) ? 1 : -1
    }
}

class separator extends ohm {
    constructor(...nodes) {
        super()
	this.nodes = nodes
    }
    [Symbol.toPrimitive]() {
        throw new Exception("not supposed to execute this")
    }
}

const ohms = {ohm,mutval,cached,timekeep,capture,control,composite,randsample,noise,sequence,
          ramps,slew,clkdiv,sinusoid,sawtooth,pwm,separator}

const mapOhms = (node, symbols) => {
    if (node.name && node.name.slice(0, 1) == 'f') {
        const n = parseInt(node.name.slice(1))
        if (!symbols[n].isOhm)
            symbols[n] = mapOhms(symbols[n], symbols)
        return symbols[n]
    }

    if (node.fn && node.fn.name in ohms)
        return new ohms[node.fn.name](...node.args.map(arg => mapOhms(arg, symbols)))

    if (node.name && node.name == 't')
        return time

    if (node.condition)
        return new composite((a, b, c) => (+a) ? (+b) : (+c), mapOhms(node.condition, symbols),
                 mapOhms(node.trueExpr, symbols), mapOhms(node.falseExpr, symbols))

	if (node.isArrayNode)
	return new mutval(node.items.map(it => mapOhms(it)))

    if (node.fn)
        return new composite(node.fn.name, ...node.args.map(arg => mapOhms(arg, symbols)))

    if ('value' in node)
        return node.value

    return node;
}

const time = new timekeep(0)
const streams = {in: [new capture(0,true), new capture(0,true)],
		 out: [new mutval(0), new mutval(0)]}
const controls = {}

class OutAudioProcessor extends AudioWorkletProcessor {
    constructor(options) {
	super(options);
	this.port.onmessage = this.newMsg
    }

    newMsg(msg) {
	const data = msg.data
	if (data.stream) {
	    const mapped = mapOhms(data.stream, data.symbols)
	    streams.out[0] = mapped.nodes[0]
	    streams.out[1] = mapped.nodes[1]
	} else if (data.control) {
	    if (data.control in controls && typeof controls[data.control] != 'number')
		controls[data.control].val = data.val
	    else controls[data.control] = data.val
	}
    }
    
    process(inputs, outputs, parameters) {
	const inL = inputs[0][0];
	const inR = inputs[0].length > 1 ? inputs[0][1] : inL
	const outL = outputs[0][0], outR = outputs[0][1]
	const sol = streams.out[0], sor = streams.out[1]
	const sil = streams.in[0], sir = streams.in[1]
	let cnt = 0, nSamp =  outL.length
	while (cnt < nSamp) {
	    sil.val = inL[cnt]*10
	    outL[cnt] = sol/10
	    sir.val = inR[cnt]*10
	    outR[cnt] = sor/10
	    cnt++
	    time.val++
	}
	return true
    }
}
registerProcessor('ohm',OutAudioProcessor)


