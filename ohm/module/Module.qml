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

    function jack(index) {
        if (typeof index == "number")
            return (index < inJacks.length) ? inJacks[index] : outJacks[index - inJacks.length];
        for (var j = 0; j < nJacks; j++) {
            var ioJack = jack(j);
            if (ioJack.label === index) return ioJack;
        }
        return undefined;
    }

    function cv(index) {
        if (typeof index == "number")
            return cvs[index].cv;
        for (var c = 0; c < cvs.length; c++) {
            var obj = cvs[c];
            if (cvs[c].label === index)
		return cvs[c].cv;
        }
        return undefined;
    }

    
    
    signal inStreamsChanged(string jackLabel, var Stream)

    property int nJacks: inJacks.length + outJacks.length
    qmlExports: ["x", "y"]

}
