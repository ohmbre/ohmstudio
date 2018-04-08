import QtQuick 2.10

import ".."
Model {
    objectName: "Patch"
    property string name
    property list<Module> modules
    property list<Cable> cables

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
        for (var c = 0; c < cables.length; c++)
            if (cables[c] !== cable)
                newCables.push(cables[c]);
        cables = newCables;
    }

    property bool cueAutoSave: false
    signal userChanges
    onUserChanges: {
        cueAutoSave = true
    }

    qmlExports: ["name","modules","cables"]

    Component.onCompleted: function() {
        Qt.patch = this;
        modulesChanged.connect(userChanges);
        cablesChanged.connect(userChanges);

        for (var m in modules) {
            modules[m].coordsChanged.connect(userChanges);
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
        }
    }

}



