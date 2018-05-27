'use strict';

const alsa = require('alsa');
const algebrite = require('./algebrite');

const device = "hw:0,0"
const channels = 2
const sampleRate = 48000
const sampleSigned = true
const sampleBytes = 4
const samplePeriod = 512
const sampleBuffer = 4096
const sampleBits = 8 * sampleBytes
const sampleMax = Math.pow(2,sampleBits)/(sampleSigned ? 2 : 1) -1
const sampleMin = sampleSigned ? -sampleMax : 0
const vMax = 10
const vMin = -10
const pi = Math.PI
const s = sampleRate
const ms = s / 1000
const m = 60*s
const vScale = (sampleMax-sampleMin)/(vMax-vMin)
const v = 1
const tau = 2*pi
const hz = tau/s

const bufferType = {2:{true:Int16Array,false:Uint16Array},
		  4:{true:Int32Array,false:Uint32Array}}[sampleBytes][sampleSigned]
	    
const notes={C:-9,Cs:-8,Db:-8,D:-7,Ds:-6,Eb:-6,E:-5,F:-4,Fs:-3,Gb:-3,G:-2,Gs:-1,Ab:-1,A:0,As:1,Bb:1,B:2}
	
function setVar(key,val) {
    algebrite.run(key+'='+val);
}
	
function setupAlgebrite() {
    algebrite.run('clearall()')
    setVar('s',s)
    setVar('ms', 's/1000')
    setVar('m', '60s')
    setVar('v', v)
    setVar('tau', '2pi')
    setVar('hz', 'tau/s')
    
    for (var note in notes) setVar(note,notes[note])
    algebrite.run('notehz(name,octave) = 440hz * (2^(1/12))^((octave-4)*12 + name)')
}

const SynthProc = genFunc => (t, ...args) => ({
    t: t.val-1,
    externt: t,
    gen: genFunc(...args),
    [Symbol.toPrimitive](hint) {
        while (this.t < this.externt.val) {
	    this.t++;
	    this.val = this.gen.next().value;
        }
	return this.val;
    }
})

const SynthFunc = func => (...args) => ({
    gen: function *(...args) {
	while (true)
	    yield func(...args)
    }(...args),
    [Symbol.toPrimitive](hint) {
	return this.gen.next().value;
    }
});

const Control = (val) => ({
    val: val,
    [Symbol.toPrimitive](hint) {
	return this.val
    }
})


const synths = {
    s: s,
    ms: ms,
    hz:hz,
    m: m,
    v: v,
    pi: pi,
    tau: tau,
    abs: SynthFunc(Math.abs),
    arccos: SynthFunc(Math.acos),
    arcsin: SynthFunc(Math.asin),
    ceiling: SynthFunc(Math.ceil),
    cos: SynthFunc(Math.cos),
    exp: SynthFunc(Math.exp),
    floor: SynthFunc(Math.floor),
    log: SynthFunc(Math.log),
    max: SynthFunc(Math.max),
    min: SynthFunc(Math.min),
    power: SynthFunc(Math.pow),
    random: SynthFunc(Math.random),
    round: SynthFunc(Math.round),
    sin: SynthFunc(Math.sin),
    sqrt: SynthFunc(Math.sqrt),
    tan: SynthFunc(Math.tan),
    arctan: SynthFunc(Math.atan),
    multiply: SynthFunc((...ops) => ops.reduce((a,b) => a*b)),
    add: SynthFunc((...ops) => ops.reduce((a,b) => a+b)),
    and: SynthFunc((...ops) => ops.reduce((a,b) => a && b)),
    test: SynthFunc((cond, tval, fval) => cond ? +tval : +fval),
    testlt: SynthFunc((val1, val2) => val1 < val2),
    mod: SynthFunc((a,b) => a % b),
    component: function(lst,idx) { return lst[idx] },
    sinusoid: SynthProc(function*(freq) {
	var phase = 0;
	while (true) {
            yield Math.sin(phase);
            phase = phase + freq; 
	}
    }),
    exec: function(stream,t) {
	return Function('t',...Object.keys(this), `return ${stream}`)(t,...Object.values(this));
    },
    controls: [[],[]]
};

function genFormat(p) {
    if (algebrite.iscons(p)) {
	var fn = genFormat(algebrite.car(p))
	p = algebrite.cdr(p)
	var accumList = []
	while (algebrite.iscons(p)) {
	    accumList.push(genFormat(algebrite.car(p)))
	    p = algebrite.cdr(p)
	}
	return fn+'('+accumList.join(',')+')'
    } else if (algebrite.isstr(p)) 
	return p.str
    else if (algebrite.isnum(p) || algebrite.isdouble(p))
	return parseFloat(p)
    
    return p.printname
}

const zeroStream = function*(){ yield 0 }();
const streams = [zeroStream,zeroStream];
const prevEqns = ['','']
const buf = new ArrayBuffer(samplePeriod * sampleBytes * channels)
const samples = new bufferType(buf);
const t = Control(0)
const audioCard = alsa.Sound(device, sampleRate, samplePeriod, sampleBuffer);

function writeOut() {
    for (var i = 0; i < samplePeriod; i++,t.val++) {
	samples[i*2] = Math.round(vScale * streams[0]);
	samples[i*2+1] = Math.round(vScale * streams[1]);
	console.log(samples[i*2+1])
    }
    audioCard.write(buf);
    setTimeout(writeOut, 0);
}

process.on('message', (msg) => {
    console.log(msg);
    const mparts = msg.split('=');
    const assignee = mparts.shift();
    const channel = parseInt(assignee.slice(8,9))
    var eqn = mparts.join('=')
    const rex = /#[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?/g
    const knobFree = eqn.replace(rex, '#')
    var match,i;
    if (knobFree == prevEqns[channel]) {
	for (i = 0; match = rex.exec(eqn); i++)
	    synths.controls[channel][i].val = parseFloat(match[0].slice(1))
    } else {
	synths.controls[channel].pop(synths.controls[channel].length);
	for (i = 0; match = rex.exec(eqn); i++) {
	    synths.controls[channel].push(Control(parseFloat(match[0].slice(1))))
	    eqn = eqn.replace(match[0],`controls[${channel}][${i}]`);
	}
	setupAlgebrite();
	const simplified = genFormat(algebrite.float(algebrite.simplify(eqn)));
	console.log(assignee+'='+simplified);
	streams[channel] = synths.exec(simplified,t);
    }
    prevEqns[channel] = knobFree;
});

setTimeout(writeOut, 0);

//setupAlgebrite();
//console.log(genFormat(algebrite.float(algebrite.simplify('test(mod(t,1/(120/m * (2)^((0)+0)))<30ms,10v,0v)'))))
//console.log(synths.exec('test(testlt(mod(t,multiply(0.00833333,m)),multiply(30,ms)),multiply(10,v),multiply(0,v))').gen)
