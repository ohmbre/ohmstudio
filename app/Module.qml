import ohm 1.0
import QtQuick

Model {
    id: mod
    property string label
    property var tags: ['untagged']
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
    property Component preview: null
    property real x
    property real y
    property bool testCreate: false    
    property var view: null

    exports: ({ x:'x', y:'y', cvs: 'default'})

    default property var contents
    onContentsChanged: {
        if (testCreate) return;
        const typeMap = [['InJack', inJacks], ['OutJack', outJacks], ['CV', cvs], ['Variable',variables]];
        typeMap.forEach(([type,container]) => {
            if (contents.modelName.endsWith(type)) {
                const cur = filterList(container, i => i.label === contents.label)
                if (cur.length) Object.keys(cur[0].exports).forEach(key => { cur[0][key] = contents[key] })
                else container.push(contents);
            }
        });
    }

    function getIndex() {
        return listIndex(parent.modules, this);
    }

    Component.onCompleted: {
        if (testCreate) return;        
        forEach(outJacks, oj => {
            if (!oj.calc) return
            oj.func = new SymbolicFunc();
            forEach(cvs, cv => {
                oj.func.setVar(cv.label, cv.volts)
                cv.voltsChanged.connect(() => { oj.func.setVar(cv.label, cv.volts) })
            })
            forEach(inJacks, ij => {
                oj.func.setVar(ij.label, ij.inFunc)
                ij.inFuncUpdated.connect((lbl,func) => { oj.func.setVar(lbl, func) })
            })
            forEach(variables, v => {
                oj.func.setVar(v.label, v.value)
                v.valueChanged.connect(() => { oj.func.setVar(v.label, v.value) })
            })
            
            oj.func.compile(oj.calc);
            oj.outFuncUpdated(oj.func);
        })
    }


    Component.onDestruction: {
        forEach(inJacks, ij => ij.destroy())
        forEach(outJacks, oj => oj.destroy())
        forEach(cvs, cv => cv.destroy())
    }




}
