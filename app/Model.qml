import QtQuick 2.11

QtObject {
    objectName: "EmptyModel"
    property QtObject view
    property QtObject parent
    property var qmlExports: []

    function toQML(indent) {
        if (!indent) indent = 0

        function objToQML(someObj,indent) {
            if (someObj.toQML) return someObj.toQML(indent)
            else if (typeof someObj == "string" || typeof someObj == "number")
                return JSON.stringify(someObj);
            else {
                console.log("couldn't serialize "+someObj);
                return "";
            }
        }

        var qml = objectName + ' {';
        for (var q in qmlExports) {
            var prop = qmlExports[q];
            var obj = this[prop];
	    if (typeof q != 'number') prop = q;
	    if (typeof obj == 'undefined') continue
            var propQml = '\n' + '\t'.repeat(indent+1) + prop + ': ';
            if (obj.push) {
                var listQml = '['
                if (obj.length > 0) listQml += '\n' + '\t'.repeat(indent+2);
                for (var i in obj) {
                    var objQml = objToQML(obj[i], indent+2);
                    if (objQml) {
                        listQml += objQml;
                        if (i < obj.length - 1) {
                            listQml += ',';
                            if (obj.length > 0)
                                listQml += '\n' + '\t'.repeat(indent+2);
                        }
                    }
                }
                if (obj.length > 0) listQml += '\n' + '\t'.repeat(indent+1)
                listQml += ']'
                qml += propQml + listQml;
            } else {
                var subQml = objToQML(obj, indent+1);
                if (subQml)
                    qml += propQml + subQml;
            }
        }
        if (qmlExports.length) qml += '\n' + '\t'.repeat(indent)
        return qml + '}';
    }

    // returns Array like ['QtQuick.Controls 2.3', 'ohm.jack.in 1.0', ...]
    function parseImports(qml) {
        // clean comments (cant find it now, but ripped from stackoverflow)
        var lines = qml.trim().replace(/\/\*[\s\S]*?\*\/|([^\\:]|^)\/\/.*$/gm, '$1').split('\n');
        var imports = {};
        for (var l in lines) {
            var line = lines[l].trim();
            if (line.length === 0) continue;
            if (line.match(/^import[\s]+/))
                imports[line.split(/\s/).slice(1).join(' ')] = true;
            else break;
        }
        return imports
    }

}
