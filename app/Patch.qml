import ohm 1.0
import QtQuick

Model {
    id: patch
    property string name
    property list<Module> modules
    property var cables: mapList(modules, m=>mapList(m.outJacks, oj=>oj.cables).reduce(concatList,[])).reduce(concatList,[])
    property var view: parent
    
    function deleteModule(dModule) {
        modules = filterList(modules, m => m !== dModule);
        dModule.destroy()
        modulesChanged()
    }

    function addModule(m, x, y) {
        modules.push(m.component.createObject(patch, {x: x, y: y}))
        modulesChanged()
    }
    
    function addCable(ij,oj) {
        var cableComponent = Qt.createComponent("qrc:/app/Cable.qml");
        if (cableComponent.status === Component.Ready) {
            var cableData = {inp: ij, out: oj};
            var cable = cableComponent.createObject(patch, cableData);
        } else
            console.log("error creating cable:", cComponent.errorString());
        cablesChanged();
    }

    function saveTo(fileName) {
        MAESTRO.write(fileName, toQML(patch))
    }

    exports: ({name:'name', modules:'modules', cables: 'default'})

    default property var looseCable
    onLooseCableChanged: {
        if (!looseCable || !looseCable.inp || !looseCable.out)
            return
        looseCable.inp = looseCable.inp
        looseCable.out = looseCable.out
        cablesChanged()
    }
}
