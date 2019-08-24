"use strict;"

import { math } from "mathjs/math.mjs"

const o = {};
global.engine = o;

o.update = (obj) => { for (var p in obj) o[p] = obj[p] }
o.pi = Math.PI
o.tau = 2*o.pi
o.s = 48000
o.ms = o.s / 1000
o.mins = 60 * o.s
o.hz = o.tau / o.s
o.v = 1

o.update({ C: -9, Cs: -8, Db: -8, D: -7, Ds: -6, Eb: -6, E: -5, F: -4, Fs: -3,
           Gb: -3, G: -2, Gs: -1, Ab: -1, A: 0, As: 1, Bb: 1, B: 2 })

const l2=Math.log2
o.update({
             min:           [ 1, 9/8,   6/5, 27/20,  3/2,  8/5,  9/5 ].map(l2),
             locrian:       [ 1, 16/15, 6/5,  4/3,  64/45, 8/5,  16/9 ].map(l2),
             maj:           [ 1, 9/8,   5/4,  4/3,   3/2,  5/3,  15/8 ].map(l2),
             dorian:        [ 1, 10/9, 32/27, 4/3,  40/27, 5/3,  16/9 ].map(l2),
             phrygian:      [ 1, 16/15, 6/5,  4/3,   3/2,  8/5,  9/5 ].map(l2),
             lydian:        [ 1, 9 /8,  5/4,  45/32, 3/2, 27/16, 15/8 ].map(l2),
             mixolydian:    [ 1, 10/9,  5/4,  4/3,   3/2,  5/3,  16/9 ].map(l2),
             minPentatonic: [ 1, 6/5,  27/20, 3/2,   9/5 ].map(l2),
             majPentatonic: [ 1, 9/8,   5/4,  3/2,   5/3 ].map(l2),
             egyptian:      [ 1, 10/9,  4/3, 40/27, 16/9 ].map(l2),
             minBlues:      [ 1, 6/5,   4/3,  8/5,   9/5 ].map(l2),
             majBlues:      [ 1, 10/9,  4/3,  3/2,   5/3 ].map(l2)
         })

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

    if (typeof(node) == 'number') return new Val(node);

    if (node.objectName == "Ohm") return node;

    if (node.name && node.name.slice(0,1) == '%') {
        const n = parseInt(node.name.slice(1))
        if (symbols[n].objectName != "Ohm")
            symbols[n] = link(symbols[n])
        return symbols[n]
    }

    if (node.fn && node.fn.name == 'separator') {
        return node.args.map(link)
    }

    if (node.name == 't') {
        let otype = Backend.link("time")
        return new otype();
    }

    let fn = node.fn
    if (fn) {
        fn = fn.name || fn
        if (!fn) throw new NodeLinkError(`fn missing name: ${node.toString()}`)
        if (fn == "control")
            return Backend.getControl(node.args[0].evaluate())
        let otype = Backend.link(fn);
        if (!otype)
            throw new NodeLinkError(`missing link fn ${fn} - ${node.toString()}`)
        if (fn == "list") {
            let elements = node.args[0];
            const index = link(node.args[1]);
            if (elements.isConstantNode)
              elements = elements.value.map(link)
            else if (elements.isArrayNode)
              elements = elements.items.map(link)
            return new otype(elements, index)
        }
        const compiledArgs = node.args.map(link)
        return new otype(...compiledArgs)
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
                const symname = `%${Object.entries(symbolmap).length}`
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
o.compiled = []

o.optimizer = (expression) => {
    const ret = {};
    ret.parsed = math.parse(expression);
    ret.desymboled = ret.parsed.transform(
        (node, path, parent) => {
            if (node.isSymbolNode && node.name in o)
                return new math.ConstantNode(o[node.name])
            return node
        });
    ret.optimized = math.simplify(
        ret.desymboled.transform(
            (node, path, parent) => math.simplify(node, o.mathrules))
        , o.mathrules);
    ret.processed = ret.optimized.transform(
        (node, parent, path) => node.isOperatorNode ?
            new math.FunctionNode(node.fn, node.args) : node)
    return ret;
}

o.setStream = (key,stream) => {
    console.log(key, stream);
    const result = o.optimizer(stream)
    o.expressions = o.expressions.filter(([k,v]) => k != key).concat([[key,result.processed]])
    const combo = new math.FunctionNode('separator',o.expressions.map(([k,v])=>v))
    let [nonRedundant, symbols] = o.uniqify(combo)
    o.compiled = o.linker(nonRedundant, symbols)
    o.expressions.forEach(
        ([k,v],i) => {
            Backend.setStream(k,o.compiled[i])
        })
}


o.setControl = Backend.setControl
o.enableScope = Backend.enableScope
o.disableScope = Backend.disableScope


class NodeLinkError extends Error {
    constructor(msg) {
        super(msg)
    }
}

o.debugStream = (stream, view) => {
    const objToHtml = (obj, fromRecur) => {
        const tag = (fromRecur) ? 'span' : 'div';
        const nextLevel = (fromRecur || 0) + 1;
        if (typeof obj == 'string')
            return `<${tag} style="color: #0e4889; cursor: default;">${obj}</${tag}>`
        else if (typeof obj == 'boolean' || obj === null || obj === undefined)
            return `<${tag}><em style="color: #06624b; cursor: default;">${obj}</em></${tag}>`
        else if (typeof obj == 'number')
            return `<${tag} style="color: #ca000a; cursor: default;">${obj}</${tag}>`
        else if (Object.prototype.toString.call(obj) == '[object Date]')
            return `<${tag} style="color: #009f7b; cursor: default;">${obj}</${tag}>`
        else if (Array.isArray(obj)) {
            let rtn = `<${tag} style="color: #666; cursor: default;">Array: [`
            if (!obj.length) return rtn + `]</${tag}>`
                rtn += `</${tag}><div style="padding-left: 20px;">`
            for (var i = 0; i < obj.length; i++)
                rtn += `<span></span>${objToHtml(obj[i], nextLevel)} ${(i < obj.length - 1) ? ', <br>' : ''}`
            return rtn + `</div><${tag} style="color: #666">]</${tag}>`
        } else if (obj && typeof obj == 'object') {
            let rtn = '', len = Object.keys(obj).length
            if (fromRecur && !len) return `<${tag} style="color: #999; cursor: default;">Object: {}</${tag}>`
            if (fromRecur) rtn += `<${tag} style="color: #0b89b6">Object: {</${tag}><div class="_stringify_recur _stringify_recur_level_${fromRecur}" style="padding-left: 20px;">`
            for (var key in obj)
                if (typeof obj[key] != 'function')
                    rtn += `<div><span style="padding-right: 5px; cursor: default;">${key}:</span>${objToHtml(obj[key], nextLevel)}</div>`
            if (fromRecur)
                rtn += `</div><${tag} style="color: #0b89b6; cursor: default;">}</${tag}>`
            return rtn;
        }
        return '';
    }
    console.log("debug",stream);
    const expr = o.optimizer(stream)
    let options = {parenthesis:'auto', implicit:'hide'}
    let body = Object.entries(expr).map(([part,tree])=>[part,'$$$'+tree.toTex(options)+'$$$<br/>'+objToHtml(tree)])
    let [node, symbols] = o.uniqify(expr.processed)
    symbols.forEach(sym => body.push([sym.symbol,sym.args[0].toTex(options)]))
    body.push(['stream','$$$'+node.toTex(options)+'$$$'])
    body.push(["compiled",o.linker(node, symbols).repr()])
    body = body.map(row=>'<tr><td>'+row.join('</td><td>')+'</td></tr>').join('\n')
    writeFile('debug/debug.html', HWIO.read(':/app/debug/debug.html').replace('_DEBUG_', body));
    view.url = `file://${HWIO.pwd()}/debug/debug.html`
}





