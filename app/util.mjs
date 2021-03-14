"use strict;"

import * as tonal from './external/tonal/tonal.mjs'
import * as midi from './external/tonal/midi.mjs'
import * as interval from './external/tonal/interval.mjs'
import * as scale from './external/tonal/scale.mjs'
import * as scaledict from './external/tonal/scale-dictionary.mjs'

global.tonal = tonal
global.midi = midi
global.interval = interval
global.scale = scale
global.scaledict = scaledict

global.forEach = (arr,fn) => {
    var len = arr.length;
    for (var i = 0; i < len; i++) {
        var ret = fn(arr[i],i);
        if (ret !== undefined)
            return ret;
    }
}

global.concatList = (l1,l2) => {
    const l3 = []
    let i;
    if (l1) {
        for (i = 0; i < l1.length; i++) l3.push(l1[i])
    }
    if (l2) {
        for (i = 0; i < l2.length; i++) l3.push(l2[i])
    }
    return l3
}

global.concat = (a,b) => a + b

global.mapList = (l,fn) => {
    const l2 = []
    if (!l) return l2
    for (let i = 0; i < l.length; i++)
      l2.push(fn(l[i]))
    return l2
}

global.filterList = (l,fn) => {
    const l2 = []
    if (!l) return l2;
    for (let i = 0; i < l.length; i++)
      if (fn(l[i]))
        l2.push(l[i])
    return l2;
}


global.centerX = (rect) => rect.x + rect.width/2
global.centerY = (rect) => rect.y + rect.height/2
global.centerInX = (insideRect, outsideRect) => outsideRect.width/2 - insideRect.width/2;
global.centerInY = (insideRect, outsideRect) => outsideRect.height/2 - insideRect.height/2;


global.dbg = (obj) => {
    console.error(obj);
    for(let link = obj; link !== null; link = Object.getPrototypeOf(link)) {
        Object.getOwnPropertyNames(link).forEach( prop => { 
                                                     console.error('    ',prop,':')
                                                     console.error(obj[prop]) 
                                                 })
    }
}


global.clip = (min,v,max) => (v > max) ? max : ((v < min) ? min : v)

global.listToArray = (l) => {
    const a = new Array(l.length)
    for (var i = 0; i < l.length; i++)
        a[i] = l[i];
    return a;
}

global.listIndex = (l,o) => {
    if (!l) return null;
    for (let i = 0; i < l.length; i++)
        if (l[i] === o) return i;
    return null;
}

global.arrayToObject = (a) => {
    const o = {};
    a.forEach(([k,v]) => { o[k] = v });
    return o;
}

global.toQML = (model) => {
    const valToQML = (o) => {
        if (typeof(o) == 'string' && o.startsWith('#'))
        return o.slice(1)
        if (o.isModel) return toQML(o)
        return JSON.stringify(o)
    }
    let entries = Object.entries(model.exports).map(
            ([propKey,lbl]) => {
                let propVal = model[propKey]
                if (propVal && propVal.call) propVal = propVal()
                if (propVal === undefined || propVal === null) return [lbl,null]
                if (propVal.push) {
                    if (propVal.length === 0) return [lbl,null]
                    const listVals = mapList(propVal,valToQML).filter(qml=>qml !== null)
                    if (listVals.length === 0) {
                        return [lbl,null];
                    }
                    if (lbl === 'default') {
                        const lvstr = listVals.join('\n')
                        return [lbl, lvstr]
                    }
                    return [lbl, '[\n' + listVals.join(', ') + '\n]'];
                }
                return [lbl, valToQML(propVal)]
            })
    .filter(([lbl,qml]) => qml !== null)
    .map(([lbl,qml]) => lbl == 'default' ? qml : `${ lbl }: ${ qml }`)
    .join('\n')

    return `${model.modelName} {\n${entries}\n}`
}
    
