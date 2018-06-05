import QtQuick 2.10

import ohm 1.0
import ohm.jack.out 1.0
import ohm.jack.in 1.0
import ohm.helpers 1.0
import ohm.cv 1.0

Model {
    objectName: "Module"

    property string label
    
    property list<InJack> inJacks
    property list<OutJack> outJacks
    property list<CV> cvs
    property real x
    property real y
    
    property var savedControlVolts
    onSavedControlVoltsChanged: {
	if (cvs.length != savedControlVolts.length) return;
	Fn.forEach(cvs, function(cv,i) {
	    cv.controlVolts = savedControlVolts[i];
	});
    }

    function jack(index) {
        if (typeof index == "number")
            return (index < inJacks.length) ? inJacks[index] : outJacks[index - inJacks.length];
        for (var j = 0; j < nJacks; j++) {
            var ioJack = jack(j);
            if (ioJack.label === index) return ioJack;
        }
        return undefined;
    }

    function inStream(label) {
	return Fn.forEach(inJacks, function(inJack) {
	    if (inJack.label == label)
		return inJack.stream
	});
    }

    function cvStream(index) {
        if (typeof index == "number")
            return cvs[index].cv;
	return Fn.forEach(cvs, function(cv) {
            if (cv.label === index)
		return cv.stream;
        });
    }

    property int nJacks: inJacks.length + outJacks.length
    qmlExports: ({x:'x', y:'y', savedControlVolts:'cvs'})

}
