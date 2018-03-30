import QtQuick 2.10

import ".."
Model {
    objectName: "Patch"
    property string name
    property list<Module> modules
    property list<Edge> edges

    function getEdge(jack) {
        console.log('checking edge');
        for (var e = 0; e < edges.length; e++) {
            if (edges[e].fromOutJack === jack)
                return edges[e].toInJack;
            if (edges[e].toInJack === jack)
                return edges[e].fromOutJack;
        }
        console.log('no edge found');
        return false;
    }

    Component.onCompleted: function() {
        Qt.patch = this;
    }
}



