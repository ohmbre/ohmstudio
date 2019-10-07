import QtQuick 2.12

Model {

    property Jack inp
    property Jack out

    property var inModuleIndex: inp && inp.parent && inp.parent.parent && listIndex(inp.parent.parent.modules, inp.parent)
    property var outModuleIndex: out && out.parent && out.parent.parent && listIndex(out.parent.parent.modules, out.parent)
    property var exportInp: inModuleIndex !== null ? `#modules[${inModuleIndex}].jack('${inp.label}')` : null
    property var exportOut: outModuleIndex !== null ? `#modules[${outModuleIndex}].jack('${out.label}')` : null

    qmlExports: ({exportInp: 'inp', exportOut: 'out'})

    Component.onDestruction: {
        if (inp) inp.cableRemoved(this);
        if (out) out.cableRemoved(this);
        if (Qt.patch) Qt.patch.userChanges();
    }

    Component.onCompleted: {
        if (!out || !inp) {
            this.destroy()
            return
        }

        out = out
        inp = inp
        parent = out

        out.cableAdded(this);
        inp.cableAdded(this);

        out.outFuncUpdated.connect(inp.updateInFunc);

        if (Qt.patch) Qt.patch.userChanges()
    }

}
