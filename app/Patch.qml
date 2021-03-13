import QtQuick

Model {
    property string name
    property list<Module> modules
    property var cables: mapList(modules, m=>mapList(m.outJacks, oj=>oj.cables).reduce(concatList,[])).reduce(concatList,[])
    onCablesChanged: {
        console.log('cables changed', cables);
    }

    function deleteModule(dModule) {
        modules = filterList(modules, m => m !== dModule);
        dModule.destroy()
        modulesChanged()
    }

    function addModule(fileUrl, x, y) {
        fileUrl = fileUrl.replace(':/app/','')
        const name = fileUrl.split('/').pop().split('.')[0]
        const c = Qt.createComponent(fileUrl)
        if (c.status === Component.Ready) {
            const m = c.createObject(this, {x: x, y: y, objectName: name, patch: this})
            modules.push(m)
        } else
            console.error("Couldn't create module:", c.errorString())
        modulesChanged()
    }
    
    function addCable(ij,oj) {
        var cableComponent = Qt.createComponent("qrc:/app/Cable.qml");
        if (cableComponent.status === Component.Ready) {
            var cableData = {inp: ij, out: oj};
            var cable = cableComponent.createObject(oj, cableData);
        } else
            console.log("error creating cable:", cComponent.errorString());
        cablesChanged();
    }

    function saveTo(fileName) {
        MAESTRO.write(fileName, this.toQML())
    }

    qmlExports: ({name:'name', modules:'modules', cables: 'default'})

    default property var looseCable
    onLooseCableChanged: {
        if (!looseCable || !looseCable.inp || !looseCable.out)
            return
        looseCable.inp = looseCable.inp
        looseCable.out = looseCable.out
        cablesChanged()
    }
}
