import QtQuick 2.15

QtObject {
    objectName: this.toString().split('_')[0]
    property QtObject view
    property QtObject parent
    property var qmlExports: []

    function toQML() {
        const valToQML = (o) => {
            if (typeof(o) == 'string' && o.startsWith('#'))
            return o.slice(1)
            if (o.toQML) return o.toQML()
            return JSON.stringify(o)
        }
        const entries =
            Object.entries(qmlExports)
            .map(([propKey,lbl]) => {
                const propVal = this[propKey]
                if (propVal === undefined || propVal === null || propVal.length === 0) return [lbl,null]
                if (propVal.push) {
                    const listVals = mapList(propVal,valToQML).filter(qml=>qml !== null)
                    if (listVals.length === 0) return [lbl,null];
                    if (lbl === 'default') return [lbl, listVals.join('\n')]
                    return [lbl, '[\n' + listVals.join(', ') + '\n]'];
                }
                return [lbl, valToQML(propVal)]
            })
            .filter(([lbl,qml]) => qml !== null)
            .map(([lbl,qml]) => lbl == 'default' ? qml : `${ lbl }: ${ qml }`)
            .join('\n')

        return `${objectName} {\n${entries}\n}`
    }


}



