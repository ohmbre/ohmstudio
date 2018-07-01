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
            var propQml = '\n' + '    '.repeat(indent+1) + prop + ': ';
            if (obj.push) {
                var listQml = '['
                if (obj.length > 0) listQml += '\n' + '    '.repeat(indent+2);
                for (var i in obj) {
                    var objQml = objToQML(obj[i], indent+2);
                    if (objQml) {
                        listQml += objQml;
                        if (i < obj.length - 1) {
                            listQml += ',';
                            if (obj.length > 0)
                                listQml += '\n' + '    '.repeat(indent+2);
                        }
                    }
                }
                if (obj.length > 0) listQml += '\n' + '    '.repeat(indent+1)
                listQml += ']'
                qml += propQml + listQml;
            } else {
                var subQml = objToQML(obj, indent+1);
                if (subQml)
                    qml += propQml + subQml;
            }
        }
        if (qmlExports.length) qml += '\n' + '    '.repeat(indent)
        return qml + '\n' + '    '.repeat(indent) + '}\n';
    }


}
