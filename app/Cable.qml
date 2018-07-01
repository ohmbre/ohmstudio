import QtQuick 2.11

Model {
    objectName: "Cable"
    property Jack inp
    property Jack out

    function toQML(indent) {
        if (!(inp && out)) return "";
        var qml = "Cable {\n";
        Fn.forEach(parent.modules, function(module,m) {
            if (module === inp.parent) {
                qml += '    '.repeat(indent+1)
		qml += 'inp: modules[' + m + '].jack("' + inp.label + '")\n'
	    }
            if (module === out.parent) {
                qml += '    '.repeat(indent+1)
		qml += 'out: modules[' + m + '].jack("' + out.label + '")\n';
	    }
        });
        qml += '    '.repeat(indent) + '}'
        return qml;
    }

    Component.onCompleted: inp.cableAdded(out)

}
