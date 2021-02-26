import QtQuick

Jack {
    id: outJack
    dir: "out"
    property var expression
    property var outFunc: null

    property list<Cable> cables
    property bool hasCable: cables.length > 0
    signal cableRemoved(Cable cable)
    onCableRemoved: {
        cables = filterList(cables, c => c !== cable)
        if (global.patch)
            global.patch.cablesUpdated()
    }
    signal cableAdded(Cable cable)
    onCableAdded: {
        cables.push(cable)
        if (global.patch)
            global.patch.cablesUpdated()
    }

    signal outFuncUpdated(var outFunc)
    function createOutFunc() {
        if (expression)
            outFunc = new SymbolicFunction(label, expression)
        outFuncUpdated(outFunc)
        return outFunc
    }

    function setVar(key,val) {
        if (outFunc) outFunc.setVar(key,val);
    }

    qmlExports: ({label: 'label'})


    Component.onDestruction: {
        while (cables.length) {
            const cbl = cables[0]
            cableRemoved(cbl)
            cbl.destroy();
        }
    }

}
