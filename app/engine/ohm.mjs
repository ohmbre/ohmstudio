"use strict;"

import { math } from "mathjs/math.mjs"

const o = {};
global.ohm = o;

o.backend = Backend
o.update = (obj,f=x=>x) => { for (var p in obj) o[p] = f(obj[p]) }
o.pi = Math.PI
o.tau = 2*o.pi
o.s = 48000
o.ms = o.s / 1000
o.mins = 60 * o.s
o.hz = o.tau / o.s
o.update({ C: -9, Cs: -8, Db: -8, D: -7, Ds: -6, Eb: -6, E: -5, F: -4, Fs: -3,
             Gb: -3, G: -2, Gs: -1, Ab: -1, A: 0, As: 1, Bb: 1, B: 2 })
o.update({minor: [1, 9/8, 6/5, 27/20, 3/2, 8/5, 9/5],
             locrian: [1, 16/15, 6/5, 4/3, 64/45, 8/5, 16/9],
             major: [1, 9/8, 5/4, 4/3, 3/2, 5/3, 15/8],
             dorian: [1, 10/9, 32/27, 4/3, 40/27, 5/3, 16/9],
             phrygian: [1, 16/15, 6/5, 4/3, 3/2, 8/5, 9/5],
             lydian: [1, 9 /8, 5/4, 45 / 32, 3/2, 27/16, 15/8],
             mixolydian: [1, 10/9, 5/4, 4/3, 3/2, 5/3, 16/9],
             minorPentatonic: [1, 6/5, 27/20, 3/2, 9/5],
             majorPentatonic: [1, 9/8, 5/4, 3/2, 5/3],
             egyptian: [1, 10/9, 4/3, 40/27, 16/9],
             minorBlues: [1, 6/5, 4/3, 8/5, 9/5],
             majorBlues: [1, 10/9, 4/3, 3/2, 5/3]}, Math.log2)

o.addMathFn = (name, fn) => {
    const type = {[name]: math.typed(name, {'number, number': fn})}
    math.import(type)
}

o.addMathFn('notehz', (name, octave) =>
                0.057595865 * 1.059463094 ** (12 * (octave - 4) + name))

o.mathrules = Array.from(math.simplify.rules)
o.mathrules.push('n/(n1/n2) -> (n*n2)/n1')
o.mathrules.push('n^n1(n2/n3) -> (n2/n3)*n^n1')
o.mathrules.push('c/(c1*n) -> (c/c1)/n')
o.mathrules.push('c*(c1*n+c2*n1) -> (c*c1)*n+(c*c2)*n1')

o.mapConstants = (node, path, parent) => {
   if (node.isSymbolNode && node.name in o)
        return new math.ConstantNode(o[node.name]);
        return node;
    }

o.omap = {
    'val': Val,
    'sinusoid': Sinusoid
}
o.backend.unaryFns().forEach((fname) => { o.omap[fname] = UnaryOp })
o.backend.binaryFns().forEach((fname) => { o.omap[fname] = BinaryOp })
o.backend.ternaryFns().forEach((fname) => { o.omap[fname] = TernaryOp })

o.mapOhms = (node, symbols) => {

    if (node.objectName == "Ohm") return node;

    if (node.name && node.name.slice(0,1) == 'f') {
        const n = parseInt(node.name.slice(1))
        if (symbols[n].objectName != "Ohm")
            symbols[n] = o.mapOhms(symbols[n], symbols)
        return symbols[n]
    }

    if (node.fn && node.fn.name == 'separator') {
        return [o.mapOhms(node.args[0], symbols), o.mapOhms(node.args[1], symbols)]
    }

    if (node.name == 't') return o.backend.time()

    if (node.fn) {
        const name = node.fn.name || node.fn
        if (!name) throw new Error("could not get node.fn name: " + node.toString())
        if (name == "control")
        return o.backend.control(node.args[0].evaluate())

        let otype = o.omap[name];
        if (!otype) throw new Error("could not find implementation for: "+name+" in node "+node.toString())
        const mappedArgs = node.args.map(arg => o.mapOhms(arg, symbols))
        if (otype == UnaryOp || otype == BinaryOp || otype == TernaryOp)
            return new otype(name, ...mappedArgs, o.backend);
        return new otype(...mappedArgs, o.backend)
    }

    if (node.isArrayNode)
        return new Error("arrays !implemented")

    if (node.isConstantNode) {
        return new Val(node.evaluate(), o.backend)
    }

    throw new Error("could not map node to implementation: " + node.toString())
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

    const symbolTransform = (node, path, parent) => node.redirect ? new math.SymbolNode(node.redirect) : node

    const sentries = Object.entries(symbolmap);
    sentries.sort((a, b) => parseInt(a[0].slice(1)) - parseInt(b[0].slice(1)))

    const symbols = sentries.map(sym => {
        let clone = sym[1].clone()
        clone.redirect = false
        clone = clone.transform(symbolTransform)
        clone.symbol = sym[0]
        return clone
    })
    let uniqified = topnode.transform(symbolTransform)

    return [uniqified, symbols]
}

o.handleMsg = (msg) => {
    if (msg.cmd == 'set' && msg.key == 'streams') {
        const simplified = msg.val.map(
            (sval) => {
                const parsed = math.parse(sval);
                const mapped = parsed.transform(o.mapConstants);
                const simpled = mapped.transform((node, path, parent) => math.simplify(node, o.mathrules))
                const resimpled = math.simplify(simpled, o.mathrules);
                const functified = resimpled.transform((node, parent, path) => node.isOperatorNode ? new math.FunctionNode(node.fn, node.args) : node)
                return functified
            })
        const combo = new math.FunctionNode('separator',simplified)
        let [uniqified, symbols] = o.uniqify(combo)
        const mapped = o.mapOhms(uniqified, symbols)
        console.log(mapped);
        o.backend.out(0,mapped[0])
        o.backend.out(1,mapped[1])
    } else if (msg.cmd == 'set' && msg.key == 'control') {
        let val = parseFloat(msg.val)
        o.backend.control(msg.subkey, val)
    } else if (msg.cmd == 'set' && msg.key == 'audioEnabled') {
        if (msg.val == false) {
            // TODO
        }
    }
}

