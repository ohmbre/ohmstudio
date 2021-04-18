import ohm 1.0
import QtQuick

Model {
    id: patch
    property list<Module> modules
    property var cables: mapList(modules, m=>mapList(m.outJacks, oj=>oj.cables).reduce(concatList,[])).reduce(concatList,[])
    
    
    function deleteModule(dModule) {
        modules = filterList(modules, m => m !== dModule);
        dModule.destroy()
    }

    function addModule(m, props) {
        modules.push(m.component.createObject(patch, props))
    }
    
    function addCable(ij,oj) {
        cableComponent.createObject(patch, {inp: ij, out: oj});
    }

}
