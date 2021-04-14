import ohm 1.0
import QtQuick

Jack {
    id: outJack
    dir: "out"
    property string header: ''
    property string calc: ''
    property var func: null
       
    property list<Cable> cables
    property bool hasCable: cables.length > 0
    signal cableRemoved(Cable cable)
    onCableRemoved: (cable) => {
        cables = filterList(cables, c => c !== cable)
        parent.parent.cablesChanged()
    }
    signal cableAdded(Cable cable)
    onCableAdded: (cable) => {
        cables.push(cable)
        parent.parent.cablesChanged()
    }

    signal outFuncUpdated(var outFunc)

    exports: ({label: 'label'})


    Component.onDestruction: {
        while (cables.length) {
            const cbl = cables[0]
            cableRemoved(cbl)
            cbl.destroy();
        }
    }

}
