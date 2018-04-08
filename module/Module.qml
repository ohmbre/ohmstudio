import ".."
Model {
    objectName: "Module"

    property string label
    //property list<CV> cvs
    property list<InJack> inJacks
    property list<OutJack> outJacks
    property point coords

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

    qmlExports: ["coords"]


}
