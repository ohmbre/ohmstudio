import QtQuick 2.10

import ohm 1.0
import ohm.module 1.0
import ohm.cable 1.0
import ohm.helpers 1.0

Model {

    objectName: "Patch"
    property string name
    property list<Module> modules
    property list<Cable> cables
    property var importList: ({'ohm.patch 1.0': true, 'ohm.cable 1.0': true})

    function lookupCableFor(jack) {
	var ret = Fn.forEach(cables, function(cable, c) {
            if (cable.out === jack)
                return {index: c, cable: cable, dir: 'out', otherend: cable.inp};
            if (cable.inp === jack)
                return {index: c, cable: cable, dir: 'inp', otherend: cable.out};
        });
	if (ret === undefined) return {cable: false};
	return ret;
    }

    function addCable(cable) {
        cables.push(cable);
        cable.parent = this;
        //cable.inp.cableAdded(cable.out) <- done in cable oncomplete
    }

    function deleteCable(dCable) {
        var newCables = [];
        Fn.forEach(cables, function(cable) {
            if (cable !== dCable)
                newCables.push(cable);
	});
        cables = newCables;
        dCable.inp.cableRemoved(dCable.out);
    }

    function deleteModule(dModule) {
        for (var j = 0; j < dModule.nJacks; j++) {
            var cableResult = lookupCableFor(dModule.jack(j));
            if (cableResult.cable)
                deleteCable(cableResult.cable, true)
        }
        var newModules = [];
	Fn.forEach(modules, function(module) {
            if (module !== dModule)
                newModules.push(module);
	});
        modules = newModules;
	dModule.destroy()
    }

    function addModule(classname, namespace, x, y) {
        var qml = "import " + namespace + '; ' + classname + " {x: "+x+"; y: "+y+"}";
        var mObj = Qt.createQmlObject(qml, this, "dynamic");
        importList[namespace] = true;
	Fn.forEach(mObj.inJacks, function(jack) { jack.parent = mObj });
	Fn.forEach(mObj.outJacks, function(jack) { jack.parent = mObj });
        mObj.parent = this;
        modules.push(mObj);
    }

    function saveTo(fileName) {
        var qml = ""
        for (var namespace in importList)
            qml += "import " + namespace + '\n'
        qml += '\n' + this.toQML();
        Fn.writeFile(fileName, qml)
    }

    function autosave() {
        cueAutoSave = false;
        this.saveTo(Constants.autoSavePath);
    }

    property bool cueAutoSave: false

    signal userChanges
    onUserChanges: {
        cueAutoSave = true
    }

    qmlExports: ({name:'name', modules:'modules', cables:'cables'})

    Component.onCompleted: function() {
        Qt.patch = this;
        cablesChanged.connect(userChanges);
        modulesChanged.connect(userChanges);
	Fn.forEach(modules, function(module) {
            module.xChanged.connect(userChanges);
            module.yChanged.connect(userChanges);
	    module.parent = Qt.patch;
	    Fn.forEach(module.inJacks, function(jack) { jack.parent = module });
	    Fn.forEach(module.outJacks, function(jack) { jack.parent = module });
        });
	Fn.forEach(cables, function(cable) {
            cable.parent = Qt.patch;
            // de-bind from module array indices so we can add/remove modules
            cable.inp = cable.inp;
            cable.out = cable.out;
        });

    }

}
