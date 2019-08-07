import QtQuick 2.11

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
        if (cvs.length !== savedControlVolts.length) return;
        forEach(cvs, function(cv,i) {
            cv.controlVolts = savedControlVolts[i];
        });
    }

    property Component display: (parent && parent.view) ? parent.view.moduleDisplay : null

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
        return forEach(inJacks, function(inJack) {
            if (inJack.label === label)
                return inJack.stream
        });
    }

    function cvStream(index) {
        if (typeof index == "number")
            return cvs[index].cv;
        return forEach(cvs, function(cv) {
            if (cv.label === index)
                return cv.stream;
        });
    }

    property int nJacks: inJacks.length + outJacks.length
    qmlExports: ({x:'x', y:'y', savedControlVolts:'cvs'})

}
