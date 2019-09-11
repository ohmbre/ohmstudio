"use strict";

import { math } from "mathjs/math.mjs"
global.math = math
math.createUnit({hz: {definition: '1 Hz', prefixes: 'short'}})

global.engine = {};

engine.setStream = (key,stream) => {
    compiler.run(
        'process', [key, stream],
        ([assemblies,symbols]) => {
            const link = (assembly) => {
                if (assembly.type === 'list') {
                    return new List(assembly.args[0].map(link), link(assembly.args[1]));
                } else if (assembly.type === 'control') {
                    return Backend.getControl(assembly.args[0])
                } else if (assembly.type === 'symbol') {
                    const n = assembly.args[0]
                    if (symbols[n].objectName !== "Ohm")
                    symbols[n] = link(symbols[n])
                    if (symbols[n].objectName !== "Ohm")
                    console.log("symbol link failure:", symbols[n]);
                    return symbols[n]
                } else if (assembly.type === 'val') {
                    return new Val(assembly.args[0])
                } else if (assembly.type === 'capture') {
                    return new Capture(assembly.args[0])
                }
                const Ohm = Backend.link(assembly.type)
                if (Ohm) return new Ohm(...assembly.args.map(link))
                console.log('COULD NOT LINK:', JSON.stringify(assembly))
                return new Val(0)
            }
            assemblies.forEach(([key,assembly]) => { Backend.setStream(key, link(assembly)) })
        })
}

engine.setControl = Backend.setControl
engine.enableScope = Backend.enableScope
engine.disableScope = Backend.disableScope

engine.debugStream = (stream,view) => {
    if (!global.compiler) return;
    compiler.run('debug',[stream],(body) => {
        writeFile('debug/debug.html', HWIO.read(':/app/debug/debug.html').replace('_DEBUG_', body));
        view.url = `file://${HWIO.pwd()}/debug/debug.html`
    })
}


//import { note, interval } from './tonal/tonal.mjs'



