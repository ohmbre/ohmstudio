"use strict";

import { math } from "mathjs/math.mjs"

const compiler = {}

compiler.symbols = {
    pi: Math.PI,
    tau: 2*Math.PI,
    s: 48000,
    ms: 48,
    mins: 60 * 48000,
    hz: 2*Math.PI / 48000,
    v: 1,
    C: -9, Cs: -8, Db: -8, D: -7, Ds: -6, Eb: -6, E: -5, F: -4, Fs: -3,
    Gb: -3,	G: -2, Gs: -1, Ab: -1, A: 0, As: 1, Bb: 1, B: 2,
    minor:           [ 1, 9/8,   6/5, 27/20,  3/2,  8/5,  9/5 ].map(Math.log2),
    locrian:       [ 1, 16/15, 6/5,  4/3,  64/45, 8/5,  16/9 ].map(Math.log2),
    major:           [ 1, 9/8,   5/4,  4/3,   3/2,  5/3,  15/8 ].map(Math.log2),
    dorian:        [ 1, 10/9, 32/27, 4/3,  40/27, 5/3,  16/9 ].map(Math.log2),
    phrygian:      [ 1, 16/15, 6/5,  4/3,   3/2,  8/5,  9/5 ].map(Math.log2),
    lydian:        [ 1, 9/8,   5/4,  45/32, 3/2, 27/16, 15/8 ].map(Math.log2),
    mixolydian:    [ 1, 10/9,  5/4,  4/3,   3/2,  5/3,  16/9 ].map(Math.log2),
    minPent:       [ 1, 6/5,   4/3,  3/2,   9/5 ].map(Math.log2),  // [ 1, 6/5,  27/20, 3/2,   9/5 ]?
    majPent:       [ 1, 9/8,   5/4,  3/2,   5/3 ].map(Math.log2),
    egyptian:      [ 1, 10/9,  4/3, 40/27, 16/9 ].map(Math.log2),
    blues:         [ 1, 6/5,   4/3, 45/32,  3/2,  9/5 ].map(Math.log2) // maj [ 1, 10/9,  4/3,  3/2,   5/3 ]?
}

math.import({['notehz']: math.typed('notehz',
    {'number, number': (name,octave) => 0.057595865 * 1.059463094 ** (12 * (octave - 4) + name) })})

compiler.rules = Array.from(math.simplify.rules)
compiler.rules.push('n/(n1/n2) -> (n*n2)/n1')
compiler.rules.push('n^n1(n2/n3) -> (n2/n3)*n^n1')
compiler.rules.push('c/(c1*n) -> (c/c1)/n')
compiler.rules.push('c*(c1*n+c2*n1) -> (c*c1)*n+(c*c2)*n1')

compiler.optimize = (expression) => {
    const parsed = math.parse(expression);
    const desymboled = parsed.transform((n,_1,_2) =>
          (n.isSymbolNode && n.name in compiler.symbols) ? new math.ConstantNode(compiler.symbols[n.name]) : n)
    const optimized = math.simplify(desymboled.transform((n,_1,_2) => math.simplify(n, compiler.rules)), compiler.rules);
    return optimized.transform((n,_1,_2) => n.isOperatorNode ? new math.FunctionNode(n.fn, n.args) : n)
}

compiler.compile = (topnode) => {
    const seen = new Map()
    const symbolmap = {}
    topnode.traverse((node,_1,_2) => { node.redirect = false })
    const queue = [topnode]
    while (queue.length) {
        const node = queue.shift()
        let nchildren = 0
        node.traverse((node,_1,_2) => { nchildren++ })
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
        node.forEach((node,_1,_2) => { queue.push(node) });
    }
    const symbolTransform = (node,_1,_2) => node.redirect ? new math.SymbolNode(node.redirect) : node
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

compiler.assembler = (node, symbols) => {
    const assembly = (type,...args) => ({assembled: true, type: type, args: args})
    const assemble = (arg) => compiler.assembler(arg, symbols)
    if (typeof(node) == 'number') return assembly('val', node);
    if (node.assembly) return node;
    if (node.name && node.name.slice(0,1) === '%') {
        const n = parseInt(node.name.slice(1))
        if (!symbols[n].assembled)
            symbols[n] = assemble(symbols[n])
        return assembly('symbol',n)
    }
    if (node.name === 't')
        return assembly('time')
    let fn = node.fn
    if (fn) {
        fn = fn.name || fn
        if (!fn) throw new NodeLinkError(`fn missing name: ${node.toString()}`)
        if (fn === "control" || fn === "capture")
            return assembly(fn,node.args[0].evaluate())
        if (fn === "list") {
            let elements = node.args[0];
            const index = assemble(node.args[1]);
            if (elements.isConstantNode)
              elements = elements.value.map(assemble)
            else if (elements.isArrayNode)
              elements = elements.items.map(assemble)
            return assembly(fn, elements, index)
        }
        const compiledArgs = node.args.map(assemble)
        return assembly(fn,...compiledArgs)
    }
    if (node.isConstantNode)
        return assembly('val',node.evaluate())
    if (node.isConditionalNode) {
        const args = [node.condition, node.trueExpr, node.falseExpr].map(assemble)
        return assembly('conditional',...args)
    }
    throw new NodeLinkError(`name:${node.name}, fn:${node.fn}:${node.fn?node.fn.name:''} - ${node.toString()}`)
}

compiler.keys = []
compiler.expressions = []

compiler.process = (key,stream) => {
    const optimized = compiler.optimize(stream)
    let idx = compiler.keys.indexOf(key)
    if (idx === -1) {
        compiler.keys.push(key)
        compiler.expressions.push(optimized)
    } else compiler.expressions[idx] = optimized
    const [compiled, symbols] = compiler.compile(new math.FunctionNode('separator',compiler.expressions))
    return [compiled.args.map((node,i)=>[compiler.keys[i],compiler.assembler(node,symbols)]), symbols]
}

class NodeLinkError extends Error {
    constructor(msg) {
        super(msg)
    }
}


compiler.debug = (stream, view) => {
    const objToHtml = (obj, fromRecur) => {
        const tag = (fromRecur) ? 'span' : 'div';
        const nextLevel = (fromRecur || 0) + 1;
        if (typeof obj == 'string')
            return `<${tag} style="color: #0e4889; cursor: default;">${obj}</${tag}>`
        else if (typeof obj == 'boolean' || obj === null || obj === undefined)
            return `<${tag}><em style="color: #06624b; cursor: default;">${obj}</em></${tag}>`
        else if (typeof obj == 'number')
            return `<${tag} style="color: #ca000a; cursor: default;">${obj}</${tag}>`
        else if (Object.prototype.toString.call(obj) === '[object Date]')
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
    const expr = compiler.optimize(stream)
    let options = {parenthesis:'auto', implicit:'hide'}
    let body = [["optimized",'$$$'+expr.toTex(options)+'$$$<br/>'+objToHtml(expr)]]
    let [node, symbols] = compiler.compile(expr)
    symbols.forEach(sym => body.push([sym.symbol,sym.args[0].toTex(options)]))
    body.push(['stream','$$$'+node.toTex(options)+'$$$'])
    body.push(['assembled',objToHtml(compiler.assembler(node, symbols))])
    return body.map(row=>'<tr><td>'+row.join('</td><td>')+'</td></tr>').join('\n')
}

WorkerScript.onMessage = (message) => {
    try {
        WorkerScript.sendMessage({ id: message.id, result: compiler[message.fn](...message.args)})
    } catch(err) {
        console.error(`

--- COMPILER EXCEPTION ---
   call:
      ${ JSON.stringify(message) }
   exception:
      ${ err.constructor.name }: ${ err.message }
   stack:
      ${ err.stack.split('\n').map(l=>'      '+l).join('\n') }

      `)
    }
}

