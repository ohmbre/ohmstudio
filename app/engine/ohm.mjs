"use strict;"

import { math } from "mathjs/math.mjs"

const O = () => {

    const assign = Object.assign
    const o = {}

    const samplePeriod = 512
    const sampleRate = 48000

    const ratioVoct = (ratio) => Math.log(ratio) / Math.log(2)
    o.consts = {
        v: 1,
        vScale: 0.1,
        s: sampleRate,
        ms: sampleRate / 1000,
        mins: 60 * sampleRate,
        hz: 2*Math.PI / sampleRate,
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
    }

    assign(o.consts, o.consts.notes)
    assign(o.consts, o.consts.scales)
    assign(o, o.consts)

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
        },
        atan: Math.atan,
        exp: Math.exp,
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
            if (id in o.controls) {
                if (typeof (o.controls[id]) == 'number')
                super(o.controls[id])
                else super(o.controls[id].val)
            } else super(0)
            this.id = id
            o.controls[id] = this;
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

    class stopwatch extends ohm {
        constructor(trig) {
            super()
            this.trig = trig
            this.timer = 0
        }
        [Symbol.toPrimitive]() {
            const siglvl = +this.trig
            if (siglvl >= 3) this.timer = 0;
            else this.timer++;
            return this.timer;
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

    class sawsin extends ohm {
        constructor(freq, decay, timer) {
            super()
            this.freq = freq
            this.phase = 0
            this.decay = decay
            this.timer = timer
        }
        [Symbol.toPrimitive]() {
            this.phase += this.freq;
            return Math.atan(Math.sin(this.phase)/(Math.cos(this.phase)+Math.exp(this.decay*this.timer)))
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
        stopwatch,ramps,slew,clkdiv,sinusoid,sawtooth,sawsin,pwm,separator}

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
        return o.time

        if (node.condition)
        return new composite((a, b, c) => (+a) ? (+b) : (+c), mapOhms(node.condition, symbols),
                             mapOhms(node.trueExpr, symbols), mapOhms(node.falseExpr, symbols))

        if (node.isArrayNode)
        return new mutval(node.items.map(it => mapOhms(it)))

        if (node.fn) {
            if (node.fn.name)
            return new composite(node.fn.name, ...node.args.map(arg => mapOhms(arg, symbols)))
            else
            return new composite(node.fn, ...node.args.map(arg => mapOhms(arg, symbols)))
        }

        if ('value' in node)
        return node.value

        return node;
    }


    o.time = new timekeep(0)
    o.streams = {in: [new capture(0,true), new capture(0,true)], out: [new mutval(0), new mutval(0)]}
    o.controls = {}

    o.addMathFn = (name, fn, sig = 'number,number') => {
        const type = {}
        const sigobj = {}; sigobj[sig] = fn
        type[name] = math.typed(name, sigobj)
        math.import(type)
        assign(o, type)
    }
    o.addMathFn('notehz', (name, octave) =>
                0.057595865 * 1.059463094 ** (12 * (octave - 4) + name))

    o.ohmrules = [...math.simplify.rules]
    o.ohmrules.push('n/(n1/n2) -> (n*n2)/n1')
    o.ohmrules.push('n^n1(n2/n3) -> (n2/n3)*n^n1')
    o.ohmrules.push('c/(c1*n) -> (c/c1)/n')
    o.ohmrules.push('c*(c1*n+c2*n1) -> (c*c1)*n+(c*c2)*n1')

    o.mapConstants = (node, path, parent) => {
        if (node.isSymbolNode && node.name in o.consts)
        return new math.ConstantNode(o.consts[node.name]);
        return node;
    }

    o.uniqify = (topnode) => {
        const seen = new Map()
        const symbolmap = {}

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
                    const symname = `f${Object.entries(symbolmap).length}`
                    other.redirect = symname
                    node.redirect = symname
                    symbolmap[symname] = other
                }
                continue
            }
            seen.set(node.rep, node)
            node.forEach((node, path, parent) => { queue.push(node) });
        }

        const symbolTransform = (node, path, parent) =>
        node.redirect ? new math.SymbolNode(node.redirect) : node

        const sentries = Object.entries(symbolmap);

        sentries.sort((a, b) => parseInt(a[0].slice(1)) - parseInt(b[0].slice(1)))

        const symbols = sentries.map(sym => {
                                  let clone = sym[1].clone()
                                  clone.redirect = false
                                  clone = new math.FunctionNode("cached",[clone.transform(symbolTransform)])
                                  clone.symbol = sym[0]
                                  return clone
                              })
        let uniqified = topnode.transform(symbolTransform)

        return [uniqified, symbols]
    }

    o.handle = (msgstr) => {
        const msg = JSON.parse(msgstr)
        if (msg.cmd == 'set' && msg.key == 'streams') {
            const simplified = msg.val.map(
                sval => math.simplify(
                    math.parse(sval)
                    .transform(o.mapConstants)
                    .transform((node, path, parent) => math.simplify(node, o.ohmrules)), o.ohmrules
                    ).transform((node, parent, path) => {
                                    if (node.isOperatorNode)
                                    return new math.FunctionNode(node.fn, node.args)
                                    return node
                                }))
            const combo = new math.FunctionNode('separator',simplified)
            let [uniqified, symbols] = o.uniqify(combo)
            const mapped = mapOhms(uniqified, symbols)
            o.streams.out[0] = mapped.nodes[0]
            o.streams.out[1] = mapped.nodes[1]
        } else if (msg.cmd == 'set' && msg.key == 'control') {
            let val = parseFloat(msg.val)
            if (!o.controls[msg.subkey] || typeof(o.controls[msg.subkey]) == 'number')
                o.controls[msg.subkey] = val
            else
                o.controls[msg.subkey].val = val
        } else if (msg.cmd == 'set' && msg.key == 'audioEnabled') {
            if (msg.val == false) {
                o.streams.out[0] = 0;
                o.streams.out[1] = 0;
            }
        } else if (msg.cmd == 'set' && msg.key == 'scopeEnabled') {
            if (msg.val == true && !o.scopeEnabled) {
                o.scopeEnabled = true
                setTimeout(o.runScope,500)
            } else if (msg.val == false && o.scopeEnabled) {
                o.scopeEnabled = false
            }
        }
    }

    /*
    o.scopeEnabled = false
    o.clip = (min,v,max) => (v > max) ? max : ((v < min) ? min : v)
    o.runScope = function() {
      const samples = new Int8Array(2*o.sampleWindow)
      let bufpos = 0
      const start = performance.now()
      let running = false
      let prevch1 = 0
      function loop() {
        for (let i = 0; i < o.samplePeriod; i++) {
          const ch1 = +o.outstreams[0]
        const ch2 = +o.outstreams[1]
        const vtrig = +o.outstreams[2]
        const window = Math.min(Math.round(o.outstreams[3]), o.scopeHistory) * 2
        if (!running && prevch1 < vtrig && ch1 >= vtrig) {
        running = true
            bufpos = 0
        } else if (running && bufpos > window) {
            running = false
            o.socket.send(new Int8Array(samples.buffer, 0, window))
            bufpos = 0
        }
        if (running) {
            samples[bufpos++] = o.clip(o.sampleMin,o.vScale * ch1,o.sampleMax) >> 24
            samples[bufpos++] = o.clip(o.sampleMin,o.vScale * ch2,o.sampleMax) >> 24
        }
        o.time.val++
        prevch1 = ch1
        }
        const delay = Math.max(o.time.val / 48 - (performance.now() - start),0)
        if (o.scopeEnabled)
        setTimeout(loop,delay)
    }
    if (o.scopeEnabled)
        setTimeout(loop,0)
    }
  */

    o.test = function() {
        o.handle('{"cmd":"set","key":"controls","subkey":1,"val":-0.07448569444468056}')
        o.handle('{"cmd":"set","key":"controls","subkey":2,"val":2.495575346116766}')
        o.handle('{"cmd":"set","key":"streams","val":["(((2 * (1.38)^((0)+control(2))))*sinusoid(((notehz(C,4) * (2)^((0)+control(1))))))","(((2 * (1.38)^((0)+control(2))))*sinusoid(((notehz(C,4) * (2)^((0)+control(1))))))"]}')
        o.handle('{"cmd":"set","key":"audioEnabled","val":true}')
    }

    o.debug = (node, symbols) => {
        const fs = require('fs');
        let options = { parenthesis: 'auto', implicit: 'hide' }
        let html = `<html><head><script src="https://unpkg.com/mathjs@4.4.2/dist/math.min.js"></script><script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default" async/></script></head><body><table>${symbols.map(n => '<tr><td>$$' + n.symbol + ':=' + n.args[0].toTex(options) + '$$</td></tr>').join('\n')}<tr></tr>${node.args.map(n=> '<tr><td>$$ch'+ node.args.indexOf(n) + ':=' + n.toTex(options) + '$$</td></tr>').join('\n')}</table></body></html>`
        fs.writeFileSync('debug.html', html);
    }

    return o

}

global.set("ohm",O());
