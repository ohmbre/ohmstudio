import QtQuick

Jack {
    dir: "inp"
    property var cable: null
    property bool hasCable: cable !== null
    signal cableRemoved()
    onCableRemoved: {
        this.cable = null;
        this.inFunc = null;
        this.inFuncUpdated(this.label, null);
    }
    signal cableAdded(Cable newCable)
    onCableAdded: (newCable) => {
        this.cable = newCable;
        updateInFunc();
    }

    property var inFunc: null
    signal inFuncUpdated(string lbl, var func)
    function updateInFunc() {
        inFunc = cable && cable.out ? cable.out.outFunc : null;
        inFuncUpdated(label, inFunc)
    }

    qmlExports: ({label:'label'})
    Component.onDestruction: {
        if (cable) cable.destroy()
    }
}
