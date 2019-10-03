import QtQuick 2.12

Jack {
    id: inJack
    dir: "inp"
    property var cable: null
    property bool hasCable: cable !== null
    property var funcRef: null
    qmlExports: ({label:'label'})
    onCableChanged: {
        if (cable) funcRef = Qt.binding(()=> cable.out.func );
        else funcRef = null
    }
    Component.onDestruction: {
        if (cable) cable.destroy();
    }
}
