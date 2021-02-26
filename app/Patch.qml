import QtQuick

Model {
    property string name
    property list<Module> modules
    property var cables: mapList(modules, m=>mapList(m.outJacks, oj=>oj.cables).reduce(concatList,[])).reduce(concatList,[])
    signal cablesUpdated()
    onCablesUpdated: {
        cables = mapList(modules, m=>mapList(m.outJacks, oj=>oj.cables).reduce(concatList,[])).reduce(concatList,[])
        if (view) view.cablesUpdated()
    }

    function deleteModule(dModule) {
        modules = filterList(modules, m => m !== dModule);
        dModule.destroy()
        if (view) view.modulesUpdated()
    }

    function addModule(fileUrl, x, y) {
        fileUrl = fileUrl.replace(':/app/','')
        const name = fileUrl.split('/').pop().split('.')[0]
        const c = Qt.createComponent(fileUrl)
        if (c.status === Component.Ready) {
            const m = c.createObject(this, {x: x, y: y, objectName: name})
            modules.push(m)
        } else
            console.error("Couldn't create module:", c.errorString())
        if (view) view.modulesUpdated()
    }

    function saveTo(fileName) {
        maestro.write(fileName, this.toQML())
    }

    qmlExports: ({name:'name', modules:'modules', cables: 'default'})

    default property var looseCable
    onLooseCableChanged: {
        if (!looseCable || !looseCable.inp || !looseCable.out)
            return
        looseCable.inp = looseCable.inp
        looseCable.out = looseCable.out
    }
}
