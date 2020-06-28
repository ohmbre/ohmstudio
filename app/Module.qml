import QtQuick 2.15

Model {
    id: mod
    property string label

    property list<InJack> inJacks
    property list<OutJack> outJacks
    property list<CV> cvs
    property list<Variable> variables

    property var jacks: concatList(inJacks,outJacks)
    property var jackMap: arrayToObject(jacks.map(j => [j.label, j]))

    property int nJacks: jacks.length
    function jack(index) {
        return (typeof index == "number") ? jacks[index] : jackMap[index]
    }

    property var cvMap: arrayToObject(mapList(cvs,cv => [cv.label, cv]))
    function cv(index) {
        return (typeof index == "number") ? cvs[index] : cvMap[index];
    }

    property var variableMap: arrayToObject(mapList(variables, v => [v.label, v]))
    function variable(index) {
        return (typeof index == 'number') ? variables[index] : variableMap[index]
    }

    property Component display: null
    property real x
    property real y
    property var view: null

    qmlExports: ({ objectName: 'objectName', x:'x', y:'y', cvs: 'default'})



    default property var contents
    onContentsChanged: {
        contents.parent = this;
        const typeMap = [['InJack', inJacks], ['OutJack', outJacks], ['CV', cvs], ['Variable',variables]];
        typeMap.forEach(([type,container]) => {
            if (contents.objectName.endsWith(type)) {
                const cur = filterList(container, i => i.label === contents.label)
                if (cur.length) Object.keys(cur[0].qmlExports).forEach(key => { cur[0][key] = contents[key] })
                else container.push(contents);
            }
        });
    }

    Component.onCompleted: {
        forEach(outJacks, oj => {
            const outFunc = oj.createOutFunc();
            if (!outFunc) return;

            forEach(cvs, cv => {
                outFunc.setVar(cv.label, cv.volts)
                cv.voltsChanged.connect(() => { outFunc.setVar(cv.label, cv.volts) })
            })
            forEach(inJacks, ij => {
                outFunc.setVar(ij.label, ij.inFunc)
                ij.inFuncUpdated.connect((lbl,func) => { outFunc.setVar(lbl, func) })
            })
            forEach(variables, v => {
                outFunc.setVar(v.label, v.value)
                v.valueChanged.connect(() => { console.log('setvvar',v.label); outFunc.setVar(v.label, v.value) })

            })

            if (outFunc.compile) outFunc.compile();
        })
    }


    Component.onDestruction: {
        forEach(inJacks, ij => ij.destroy())
        forEach(outJacks, oj => oj.destroy())
        forEach(cvs, cv => cv.destroy())
    }




}
