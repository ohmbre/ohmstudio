"use strict;"

import { math } from "mathjs/math.mjs"

const o = {};
global.engine = o;

o.update = (obj,f=x=>x) => { for (var p in obj) o[p] = f(obj[p]) }
o.pi = Math.PI
o.tau = 2*o.pi
o.s = 48000
o.ms = o.s / 1000
o.mins = 60 * o.s
o.hz = o.tau / o.s
o.v = 1
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


o.linker = (node, symbols) => {

    const link = (arg) => o.linker(arg, symbols)

    if (node.objectName == "Ohm") return node;

    if (node.name && node.name.slice(0,1) == 'f') {
        const n = parseInt(node.name.slice(1))
        if (symbols[n].objectName != "Ohm")
            symbols[n] = link(symbols[n])
        return symbols[n]
    }

    if (node.fn && node.fn.name == 'separator') {
        return node.args.map(link)
    }

    if (node.name == 't') return Backend.time()

    let fn = node.fn
    if (fn) {
        fn = fn.name || fn
        if (!fn) throw new NodeLinkError(`fn missing name: ${node.toString()}`)
        if (fn == "control")
            return Backend.getControl(node.args[0].evaluate())
        let otype = Backend.link(fn);
        if (!otype)
            throw new NodeLinkError(`missing link fn ${fn} - ${node.toString()}`)
        const linkedArgs = node.args.map(link)
        return new otype(...linkedArgs)
    }

    if (node.isArrayNode)
        return new NodeLinkError('arrays !implemented')

    if (node.isConstantNode)
        return new Val(node.evaluate())

    if (node.isConditionalNode) {
        const args = [node.condition, node.trueExpr, node.falseExpr].map(link)
        return new Conditional(...args)
    }

    throw new NodeLinkError(`name:${node.name}, fn:${node.fn}:${node.fn?node.fn.name:''} - ${node.toString()}`)
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

o.expressions = []

o.setStream = (key,stream) => {
    const parsed = math.parse(stream);
    const withSymSubs = parsed.transform(
        (node, path, parent) => (node.isSymbolNode && node.name in o) ?
            new math.ConstantNode(o[node.name]) : node);
    const optimized = math.simplify(
        withSymSubs.transform(
            (node, path, parent) => math.simplify(node, o.mathrules)), o.mathrules);
    const expression = optimized.transform(
        (node, parent, path) => node.isOperatorNode ?
            new math.FunctionNode(node.fn, node.args) : node)
    o.expressions = o.expressions.filter(([k,v]) => k != key).concat([[key,expression]])

    const combo = new math.FunctionNode('separator',o.expressions.map(([k,v])=>v))
    let [nonRedundant, symbols] = o.uniqify(combo)
    const linked = o.linker(nonRedundant, symbols)
    o.expressions.forEach(([k,v],i) => Backend.setStream(k,linked[i]))
}

o.setControl = Backend.setControl


class NodeLinkError extends Error {
    constructor(msg) {
        super(msg)
    }
}

console.log(Backend.getControl(2))
