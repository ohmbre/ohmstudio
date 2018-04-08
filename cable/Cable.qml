import ".."

Model {
    objectName: "Cable"
    property Jack inp
    property Jack out

    function toQML(indent) {
        var qml = "Cable {\n";
        for (var m in parent.modules) {
            if (parent.modules[m] === inp.parent)
                qml += '\t'.repeat(indent+1) + 'inp: modules[' + m + '].jack("' + inp.label + '")\n';
            if (parent.modules[m] === out.parent)
                qml += '\t'.repeat(indent+1) + 'out: modules[' + m + '].jack("' + out.label + '")\n';
        }
        qml += '\t'.repeat(indent) + '}'
        return qml;
    }
}
