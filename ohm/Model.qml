import QtQuick 2.10

QtObject {
    objectName: "EmptyModel"
    property QtObject view
    property QtObject parent
    property var qmlExports: []

    function toQML(indent) {
        if (!indent) indent = 0
        function objToQML(someObj,indent) {
            if (someObj.toQML) return someObj.toQML(indent)
            else if (someObj.toString().indexOf("QPoint") === 0)
                return '"' + someObj.x + ',' + someObj.y + '"'
            else return JSON.stringify(someObj);
        }

        var qml = objectName + ' {';
        for (var q in qmlExports) {
            var prop = qmlExports[q];
            var obj = this[prop];
            qml += '\n' + '\t'.repeat(indent+1) + prop + ': ';
            if (obj.push) {
                qml += '['
                if (obj.length > 0) qml += '\n' + '\t'.repeat(indent+2);
                for (var i in obj) {
                    qml += objToQML(obj[i], indent+2);
                    if (i < obj.length - 1) {
                        qml += ',';
                        if (obj.length > 0) qml += '\n' + '\t'.repeat(indent+2);
                    }
                }
                if (obj.length > 0) qml += '\n' + '\t'.repeat(indent+1)
                qml += ']'
            } else
                qml += objToQML(obj, indent+1);
        }
        if (qmlExports.length) qml += '\n' + '\t'.repeat(indent)
        return qml + '}';
    }

    // returns Array like ['QtQuick.Controls 2.3', 'ohm.jack.in 1.0', ...]
    function parseImports(qml) {
    // clean comments (cant find it now, but I ripped it from a good-looking man on stackoverflow)
    var lines = qml.trim().replace(/\/\*[\s\S]*?\*\/|([^\\:]|^)\/\/.*$/gm, '$1').split('\n');
    var imports = [];
    for (var l in lines) {
        var line = lines[l].trim();
        if (line.length === 0) continue;
        if (line.match(/^import[\s]+/))
        imports.push(line.split(/\s/).slice(1).join(' '));
        else break;
    }
    return imports
    }

}
