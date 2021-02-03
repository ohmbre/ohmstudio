import QtQuick
import ohm 1.0

Model {
    property string name
    property list<Module> modules
    property var cables: mapList(modules, m=>mapList(m.outJacks, oj=>oj.cables).reduce(concatList,[])).reduce(concatList,[])
    signal cablesUpdated()
    onCablesUpdated: {
        cables = mapList(modules, m=>mapList(m.outJacks, oj=>oj.cables).reduce(concatList,[])).reduce(concatList,[])
    }

    function deleteModule(dModule) {
        modules = filterList(modules, m => m !== dModule);
        dModule.destroy()
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

    }

    function saveTo(fileName) {
        var qml = 'import ohm 1.0\n' + this.toQML();
        FileIO.write(fileName, qml)
    }

    qmlExports: ({name:'name', modules:'modules', cables: 'default'})

    Component.onCompleted: {
        global.patch = this
    }

    default property var looseCable
    onLooseCableChanged: {
        if (!looseCable || !looseCable.inp || !looseCable.out)
            return
        looseCable.inp = looseCable.inp
        looseCable.out = looseCable.out
    }
}
