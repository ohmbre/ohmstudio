import QtQuick 2.10

import ".."
Model {
    objectName: "Patch"
    property string name
    property list<Module> modules
    property list<Edge> edges
    Component.onCompleted: function() {
        Qt.patch = this;
        /*for (var m = 0; m < modules.length; m++) {
            modules[m].patch = this;
            for (var i = 0; i < modules[m].inJacks.length; i++)
                modules[m].inJacks[i].module = this;
            for (var o = 0; o < modules[m].outJacks.length; o++)
                modules[m].outJacks[o].module = this;
        }*/
    }
}



