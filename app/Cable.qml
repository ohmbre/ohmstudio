import QtQuick 2.15

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
    }

    Component.onCompleted: {

        if (out) out = out
        if (inp) inp = inp
        if (out) parent = out

        if (out) out.cableAdded(this);
        if (inp) inp.cableAdded(this);

        if (out && inp && inp.updateInFunc) out.outFuncUpdated.connect(inp.updateInFunc);
    }

}
