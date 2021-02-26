import QtQuick

Model {

    property var inp
    property var out

    function exportInp() {
        if (!inp || !inp.module) return null
        const modIdx = inp.module.getIndex()
        if (modIdx === null) return null
        return `#modules[${modIdx}].jack('${inp.label}')`
    }

    function exportOut() {
        if (!out || !out.module) return null
        const modIdx = out.module.getIndex()
        if (modIdx === null) return null
        return `#modules[${modIdx}].jack('${out.label}')`
    }

    qmlExports: ({exportInp: 'inp', exportOut: 'out'})

    Component.onDestruction: {
        if (inp) inp.cableRemoved();
        if (out) out.cableRemoved(this);
    }

    Component.onCompleted: {

        if (out) out = out
        if (inp) inp = inp

        if (out) out.cableAdded(this);
        if (inp) inp.cableAdded(this);

        if (out && inp && inp.updateInFunc) out.outFuncUpdated.connect(inp.updateInFunc);
    }

}
