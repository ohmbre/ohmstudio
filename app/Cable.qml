import QtQuick

Model {

    property var inp
    property var out

    property var exportInp: {
        if (!inp) { console.log('!inp'); return null }
        if (!inp.module) { console.log('!inp.module'); return null }
        const modIdx = inp.module.getIndex()
        if (modIdx === null) { console.log('!inp.module.getIndex'); return null }
        return `#modules[${modIdx}].jack('${inp.label}')`
    }

    property var exportOut: {
        if (!out) { console.log('!out'); return null }
        if (!out.module) { console.log('!out.module'); return null }
        const modIdx = out.module.getIndex()
        if (modIdx === null) { console.log('!out.module.getIndex'); return null }
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
