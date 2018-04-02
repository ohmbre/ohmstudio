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

    function deleteCable(cable) {
        var newCables = [];
        for (var c = 0; c < cables.length; c++)
            if (cables[c] !== cable)
                newCables.push(cables[c]);
        cables = newCables;
    }


    Component.onCompleted: function() {
        Qt.patch = this;
    }
}



