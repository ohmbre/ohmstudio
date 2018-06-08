import ohm.jack 1.0
import ohm.helpers 1.0
Jack {
    objectName: "OutJack"
    dir: "out"
    property string parsedStream: {
	var match, parsed=stream;
	while (match = (/@[a-zA-z][a-zA-Z0-9]*/g).exec(parsed))
	    parsed = parsed.replace(match,'(%1)'.arg(cvStream(match[0].slice(1))));
	while (match = (/\$[a-zA-z][a-zA-Z0-9]*/g).exec(parsed))
	    parsed = parsed.replace(match,'(%1)'.arg(inStream(match[0].slice(1))));
	return '(%1)'.arg(parsed)
    }
}
