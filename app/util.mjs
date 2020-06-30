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
    for (var prop in obj)
    console.error("      "+prop+": "+obj[prop]);
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


