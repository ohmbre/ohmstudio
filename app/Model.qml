import QtQuick

QtObject {
    objectName: this.toString().split('_')[0]
    property var view
    property var qmlExports: []

    function toQML() {
        const valToQML = (o) => {
            if (typeof(o) == 'string' && o.startsWith('#'))
            return o.slice(1)
            if (o.toQML) return o.toQML()
            return JSON.stringify(o)
        }
        let entries = Object.entries(qmlExports).map(
                ([propKey,lbl]) => {
                    const propVal = this[propKey]
                    if (propVal === undefined || propVal === null || propVal.length === 0) return [lbl,null]
                    if (propVal.push) {
                        const listVals = mapList(propVal,valToQML).filter(qml=>qml !== null)
                        if (listVals.length === 0) {
                            return [lbl,null];
                        }
                        if (lbl === 'default') {
                            const lvstr = listVals.join('\n')
                            //console.log(lvstr)
                            return [lbl, lvstr]
                        }
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



