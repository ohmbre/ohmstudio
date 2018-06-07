import ohm.jack 1.0
import ohm.helpers 1.0
Jack {
    objectName: "OutJack"
    dir: "out"
    property string parsedStream: {
	var re = /@[a-zA-z][a-zA-Z0-9]*/g
	var match, parsed=stream;
	while (match = re.exec(parsed))
	    parsed = parsed.replace(match,'(%1)'.arg(cvStream(match[0].slice(1))));
	re = /\$[a-zA-z][a-zA-Z0-9]*/g
	while (match = re.exec(parsed))
	    parsed = parsed.replace(match,'(%1)'.arg(inStream(match[0].slice(1))));
	//console.log(parsed);
	return '(%1)'.arg(parsed)
    }
}
