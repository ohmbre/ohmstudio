.pragma library

function stringWrap(funcName,args) {
    var ret = funcName + "(";
    if (args.length) {
	ret += args[0];
	for (var i = 1; i < args.length; i++)
	    ret += ','+args[i];
    }
    ret += ')';
    return ret;
}

function moduloCounter() { return stringWrap('moduloCounter', arguments); }
function xmap() { return stringWrap('xmap', arguments); }
function sinusoid() { return stringWrap('sinusoid', arguments); }
function oneshot() { return stringWrap('oneshot', arguments); }
function saw() { return stringWrap('saw', arguments); }
function mul() { return stringWrap('mul',arguments); }
function add() { return stringWrap('add',arguments); }
function pow2() { return stringWrap('pow2',arguments); }
function repeat() { return stringWrap('repeat',arguments); }
function noteToHz() { return stringWrap('noteToHz',arguments); }
function cycle() { return stringWrap('cycle',arguments); }
function scaleToVoct() { return stringWrap('scaleToVoct',arguments); }
function sample() { return stringWrap('sample',arguments); }
function clockSeq() { return stringWrap('clockSeq', arguments); }





