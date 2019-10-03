import QtQuick 2.12
import ohm 1.0

Model {
    property string name
    property list<Module> modules
    property var cables: mapList(modules, m=>mapList(m.outJacks, oj=>oj.cables).reduce(concatList,[])).reduce(concatList,[])

    function deleteModule(dModule) {
        forEach(dModule.outJacks, oj => {
                    while (oj.cables.length !== 0)
                      oj.cables[0].remove()
                })
        modules = filterList(modules, m => m !== dModule);
        dModule.destroy()
        userChanges()
    }

    function addModule(fileUrl, x, y) {
        fileUrl = fileUrl.replace(':/app/','');
        const name = fileUrl.split('/').pop().split('.')[0]
        const c = Qt.createComponent(fileUrl);
        if (c.status === Component.Ready) {
            const m = c.createObject(this, {x: x, y: y, objectName: name})
            m.parent = this;
            m.xChanged.connect(userChanges)
            m.yChanged.connect(userChanges)
            modules.push(m);
        } else
            console.error("Couldn't create module:", c.errorString())

    }

    function saveTo(fileName) {
        var qml = 'import ohm 1.0\n' + this.toQML();
        writeFile(fileName, qml)
    }

    function autosave() {
        cueAutoSave = false;
        this.saveTo('patches/autosave.qml');
    }

    property bool cueAutoSave: false

    signal userChanges
    onUserChanges: {
        cueAutoSave = true
    }

    qmlExports: ({name:'name', modules:'modules', cables: 'default'})

    Component.onCompleted: {
        Qt.patch = this;
        modulesChanged.connect(userChanges)
        forEach(modules, function(module) {
            module.xChanged.connect(userChanges)
            module.yChanged.connect(userChanges)
            module.parent = Qt.patch
        })
    }

    default property var looseCable
    onLooseCableChanged: {
        if (!looseCable || !looseCable.inp || !looseCable.out)
            return
        looseCable.inp = looseCable.inp
        looseCable.out = looseCable.out
    }
}
