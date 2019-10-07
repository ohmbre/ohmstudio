import QtQuick 2.12

Jack {
    id: outJack
    dir: "out"
    property var expression
    property var stateVars: ({})
    property var outFunc: null

    property list<Cable> cables
    property bool hasCable: cables.length > 0
    signal cableRemoved(Cable cable)
    onCableRemoved: {
        cables = filterList(cables, c => c !== cable)
    }
    signal cableAdded(Cable cable)
    onCableAdded: {
        cables.push(cable)
    }

    signal outFuncUpdated(var outFunc)
    function createOutFunc() {
        outFunc = new SymbolicFunction(label, expression, stateVars)
        outFuncUpdated(outFunc)
        return outFunc
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
