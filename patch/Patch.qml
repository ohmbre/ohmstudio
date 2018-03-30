import QtQuick 2.10

import ".."
Model {
    objectName: "Patch"
    property string name
    property list<Module> modules
    property list<Cable> cables

    function getCable(jack) {
        for (var e = 0; e < cables.length; e++) {
            if (cables[e].fromOutJack === jack)
                return cables[e].toInJack;
            if (cables[e].toInJack === jack)
                return cables[e].fromOutJack;
        }
        return false;
    }

    Component.onCompleted: function() {
        Qt.patch = this;
    }
}



