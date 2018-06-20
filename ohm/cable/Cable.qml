import QtQuick 2.11
import ohm 1.0
import ohm.jack 1.0
import ohm.helpers 1.0

Model {
    objectName: "Cable"
    property Jack inp
    property Jack out

    function toQML(indent) {
	if (!(inp && out)) return ""; 
        var qml = "Cable {\n";
	Fn.forEach(parent.modules, function(module,m) {
            if (module === inp.parent)
                qml += '\t'.repeat(indent+1) + 'inp: modules[' + m + '].jack("' + inp.label + '")\n';
            if (module === out.parent)
                qml += '\t'.repeat(indent+1) + 'out: modules[' + m + '].jack("' + out.label + '")\n';
        });
        qml += '\t'.repeat(indent) + '}'
        return qml;
    }

    Component.onCompleted: inp.cableAdded(out)

}
