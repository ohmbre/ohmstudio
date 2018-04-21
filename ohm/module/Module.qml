import ohm 1.0
import ohm.jack.out 1.0
import ohm.jack.in 1.0
import ohm.helpers 1.0

Model {
    objectName: "Module"

    property string label
    //property list<CV> cvs
    property list<InJack> inJacks
    property list<OutJack> outJacks
    property real x;
    property real y;

    function jack(index) {
        if (typeof index == "number")
            return (index < inJacks.length) ? inJacks[index] : outJacks[index - inJacks.length];
        for (var j = 0; j < nJacks; j++) {
            var ioJack = jack(j);
            if (ioJack.label === index) return ioJack;
        }
        return undefined;
    }

    property int nJacks: inJacks.length + outJacks.length

    qmlExports: ["x", "y"]

    property var pyLoops: []
    property string pySetup: ""

}
