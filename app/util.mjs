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


global.logistic = (loval,hival,zeroval,growth) => {
    const a = hival-loval
    const za = (zeroval-loval)/a
    return (v) => loval + a*Math.pow(za, Math.exp(-growth*v))
}

global.lastAutoSave = ''

global.savePatch = (patch,fileName)  => {
    const p = {modules: [], cables: []}
    forEach(patch.modules, (module,idx) => {
        const m = {x: module.x, y: module.y, cvs: [], idx: idx, name:module.getModelName()}
        forEach(module.cvs, cv => { m.cvs.push({label: cv.label, volts: cv.volts}) })
        forEach(module.save, field => { m[field] = module[field] })
        p.modules.push(m)
    })
    forEach(patch.cables, cable => {
        const jackRep = j => ({ midx: listIndex(patch.modules, j.parent), label: j.label })
        p.cables.push({ inp: jackRep(cable.inp), out: jackRep(cable.out) })
    })
    const data = JSON.stringify(p,null,2)
    if (fileName == 'autosave.json') {
        if (lastAutoSave == data) return;
        lastAutoSave = data;
    }
    MAESTRO.write(fileName, data)
}

global.loadPatch = (patch,fileName) => {
    const data = MAESTRO.read(fileName)
    if (!data) return false;
    const p = JSON.parse(data)
    const createdModules = []
    p.modules.forEach((m,idx) => {
        const def = moduleDefs[m.name]
        if (def) {
            const props = {}
            Object.keys(m).forEach(k=>{
                if (['cvs','idx','name'].indexOf(k) < 0)
                props[k] = m[k]              
            })
            patch.addModule(def, props)
            createdModules.push(patch.modules[patch.modules.length-1])
        } else console.error("Could not find definition for module",m.name)
    })
    p.cables.forEach(c => {
        patch.addCable(createdModules[c.inp.midx].jack(c.inp.label),
                       createdModules[c.out.midx].jack(c.out.label))
    })
    return true
}

global.moduleDefs = {}

global.loadModules = (parent) => { 
    MAESTRO.listDir('modules','*Module.qml',"modules")
    .map(path => {
             const name = path.split('/').pop().split('.')[0]
             const c = MAESTRO.loadModule(name)
             if (c.status !== 1) {
                 console.error("Error creating module", c.errorString());
                 return;
             }
             const m = c.createObject(parent, {testCreate: true});
             moduleDefs[name] = {label:m.label,tags:m.tags,path:path,name:name,component:c}
             m.destroy()
    })
}

global.listModules = (tag) => {
    if (!tag || tag == '..') return listTags()
    let ms = Object.values(moduleDefs).filter(m => m.tags.includes(tag))                
    ms.sort((a,b) => a.label.toUpperCase() < b.label.toUpperCase() ? -1 : 1)
    return [{label: '..', isTag: true}].concat(ms)
}

global.listTags = () => {
    let tags = new Set()
    Object.values(moduleDefs).forEach(m => m.tags.forEach(t => tags.add(t)))
    return [...tags].map(t => ({label: t, isTag: true}))
}

global.cableComponent = Qt.createComponent("qrc:/app/Cable.qml")
global.patchComponent = Qt.createComponent("qrc:/app/Patch.qml")
