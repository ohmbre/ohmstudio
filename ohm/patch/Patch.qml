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
    property var importList: []

    function lookupCableFor(jack) {
        for (var c = 0; c < cables.length; c++) {
            if (cables[c].out === jack)
                return {index: c, cable: cables[c], dir: 'out', otherend: cables[c].inp};
            if (cables[c].inp === jack)
                return {index: c, cable: cables[c], dir: 'inp', otherend: cables[c].out};
        }
        return {cable: false};
    }

    function addCable(cable) {
        cables.push(cable);
        cable.parent = this;
    }

    function deleteCable(cable) {
        var newCables = [];
        for (var c in cables)
            if (cables[c] !== cable)
                newCables.push(cables[c]);
        cables = newCables;
    }

    function deleteModule(module) {
        for (var j = 0; j < module.nJacks; j++) {
            var cableResult = lookupCableFor(module.jack(j));
            if (cableResult.cable)
                deleteCable(cableResult.cable, true)
        }
        var newModules = [];
        for (var m in modules)
            if (modules[m] !== module)
                newModules.push(modules[m]);
        modules = newModules;
    }

    function addModule(module, namespace) {
        var namespaceFound = false
        for (var i in importList)  {
            if (importList[i] === namespace)
                namespaceFound = true;
        }
        if (!namespaceFound)
            importList.push(namespace);
        modules.push(module);
        modules.parent = this;
    }

    property bool cueAutoSave: false
    function autosave() {
        cueAutoSave = false;
        var qml = ""
        for (var i in importList)
            qml += "import " + importList[i] + '\n'
        qml += '\n' + this.toQML();
        Fn.writeFile(Constants.autoSavePath, qml)
    }
    signal userChanges
    onUserChanges: {
        cueAutoSave = true
    }

    qmlExports: ["name","modules","cables"]

    Component.onCompleted: function() {
        Qt.patch = this;
        cablesChanged.connect(userChanges);
        modulesChanged.connect(userChanges);
        for (var m in modules) {
            modules[m].xChanged.connect(userChanges);
            modules[m].yChanged.connect(userChanges);
        }

        // assign all the 'parent' properties to children
        for (m in modules) {
            modules[m].parent = this;
            for (var j in modules[m].inJacks)
                modules[m].inJacks[j].parent = modules[m];
            for (j in modules[m].outJacks)
                modules[m].outJacks[j].parent = modules[m];
        }

        for (var c in cables) {
            cables[c].parent = this;
            // de-bind from module array indices so we can add/remove modules
            cables[c].inp = cables[c].inp;
            cables[c].out = cables[c].out;
        }
    }

}



