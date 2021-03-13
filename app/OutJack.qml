import QtQuick

Jack {
    id: outJack
    dir: "out"
    property var expression
    property var outFunc: null

    property list<Cable> cables
    property bool hasCable: cables.length > 0
    signal cableRemoved(Cable cable)
    onCableRemoved: (cable) => {
        cables = filterList(cables, c => c !== cable)
        pView.patch.cablesChanged()
    }
    signal cableAdded(Cable cable)
    onCableAdded: (cable) => {
        cables.push(cable)
        pView.patch.cablesChanged()
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
