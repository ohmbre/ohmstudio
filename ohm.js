window.ohmengine = (function() {   

    const sampleRate = 48000
    
    const ConstantNode = math.expression.node.ConstantNode
    const FunctionNode = math.expression.node.FunctionNode
    const SymbolNode = math.expression.node.SymbolNode

    const assign = Object.assign
    const o = {}
    
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
            return new ConstantNode(o.consts[node.name]);
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

    o.handle = function (msg) {
	msg = JSON.parse(msg)
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
	    o.processed = {stream:uniqified,symbols: symbols}
	    o.worklet.port.postMessage(o.processed)
            
        } else if (msg.cmd == 'set' && msg.key == 'control') {
            let val = parseFloat(msg.val)
	    o.worklet.port.postMessage({control: msg.subkey, val: val})
        } else if (msg.cmd == 'set' && msg.key == 'audioEnabled') {
	    if (msg.val == false) {
		o.worklet.port.postMessage({stream:{nodes:[0,0]},symbols:[]})
	        console.log('audio disabled')
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

    o.ctx = new AudioContext({sampleRate: o.sampleRate, latencyHint:0.2})
    o.ctx.audioWorklet.addModule('audio.js').then(() => {
	const options = {numberOfOutputs: 1, outputChannelCount: [2]}
	o.worklet = new AudioWorkletNode(o.ctx,'ohm', options)
	o.worklet.connect(o.ctx.destination)
	navigator.mediaDevices.getUserMedia({ audio:true, video:false })
	    .then((stream) => {
		o.captureNode = o.ctx.createMediaStreamSource(stream)
		o.captureNode.connect(o.worklet)
	    }).catch((err) => {
		console.log('couldnt get mic:',err);
	    })
    }).catch((err) => {
	console.log('couldnt create a worklet:',err);
    })

    //o.scopeEnabled = false    
    //o.clip = (min,v,max) => (v > max) ? max : ((v < min) ? min : v)
    /*o.runScope = function() {
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
    }*/

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
})()
