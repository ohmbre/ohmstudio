import QtQuick 2.12

Model {
    id: cmodel
    property Jack inp
    property Jack out

    property var inModuleIndex: inp && inp.parent && inp.parent.parent && listIndex(inp.parent.parent.modules, inp.parent)
    property var outModuleIndex: out && out.parent && out.parent.parent && listIndex(out.parent.parent.modules, out.parent)
    property var exportInp: inModuleIndex !== null ? `#modules[${inModuleIndex}].jack('${inp.label}')` : null
    property var exportOut: outModuleIndex !== null ? `#modules[${outModuleIndex}].jack('${out.label}')` : null

    qmlExports: ({exportInp: 'inp', exportOut: 'out'})

    function remove() {

        if (inp) inp.cable = null;
        if (out) out.cables = filterList(out.cables, c => c !== cmodel)
        cmodel.destroy();
        if (Qt.patch) Qt.patch.userChanges();
    }

    Component.onCompleted: {
        if (!out || !inp) {
            this.remove()
            return
        }
        out = out
        inp = inp
        parent = out

        out.cables.push(this)
        inp.cable = this
        if (Qt.patch) Qt.patch.userChanges()
    }

}
