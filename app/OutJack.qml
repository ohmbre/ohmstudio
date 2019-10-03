import QtQuick 2.12

Jack {
    id: outJack
    dir: "out"
    property var expression
    property var func: new SymbolicFunction(label,
                                            expression instanceof Array ? expression.join('; ') : expression,
                                            mapList(parent.inJacks, ij=>ij.label))
    property var funcRefs: mapList(parent.inJacks, ij=>[ij.label,ij.funcRef])
    property var vars: mapList(parent.cvs, cv=>[cv.label,cv.volts])
    property list<Cable> cables
    property bool hasCable: cables.length > 0
    onFuncRefsChanged: {
        forEach(funcRefs, ([fname,ref]) => {func.setFuncRef(fname, ref)});
    }
    onVarsChanged: {
        forEach(vars, ([vname, val]) => {func.setVar(vname,val)})
    }
    qmlExports: ({label: 'label'})

    Component.onDestruction: {
        while (cables.length) {
            cables[0].destroy();
        }
    }

}
