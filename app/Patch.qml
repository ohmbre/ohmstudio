import QtQuick 2.11

Model {

    objectName: "Patch"
    property string name
    property list<Cable> cables
    property list<Module> modules

    function lookupCableFor(jack) {
        var ret = forEach(cables, function(cable, c) {
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
    }

    function deleteCable(dCable) {
        var newCables = [];
        forEach(cables, function(cable) {
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
        forEach(modules, function(module) {
            if (module !== dModule)
                newModules.push(module);
        });
        modules = newModules;
        dModule.destroy()
    }

    function addModule(fileUrl, x, y) {
        var fileData = readFile(fileUrl)
        var mObj = Qt.createQmlObject(fileData, this, fileUrl)
        mObj.x = x; mObj.y = y
        forEach(mObj.inJacks, function(jack) { jack.parent = mObj });
        forEach(mObj.outJacks, function(jack) { jack.parent = mObj });
        mObj.parent = this;
        modules.push(mObj);
    }

    function saveTo(fileName) {
        var qml =
        'import ohm 1.0\n' +
        'import modules 1.0\n\n'
        qml += this.toQML();
        writeFile(fileName, qml)
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
        Qt.patch = this
        cablesChanged.connect(userChanges)
        modulesChanged.connect(userChanges)
        forEach(modules, function(module) {
            module.xChanged.connect(userChanges)
            module.yChanged.connect(userChanges)
            module.parent = Qt.patch
            forEach(module.inJacks, function(jack) { jack.parent = module })
            forEach(module.outJacks, function(jack) { jack.parent = module })
        })

        forEach(cables, function(cable) {
            cable.parent = Qt.patch
            // de-bind from module array indices so we can add/remove modules
            cable.inp = cable.inp
            cable.out = cable.out
        })
    }
}
