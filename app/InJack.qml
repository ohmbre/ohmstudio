import QtQuick

Jack {
    dir: "inp"
    property Cable cable
    property bool hasCable: cable !== null
    signal cableRemoved()
    onCableRemoved: {
        cable = null;
        updateInFunc()
    }
    signal cableAdded(Cable newCable)
    onCableAdded: (newCable) => {
        cable = newCable;
        updateInFunc();
    }

    property var inFunc: null
    signal inFuncUpdated(string lbl, var func)
    function updateInFunc() {
        inFunc = cable && cable.out ? cable.out.func : null;
        inFuncUpdated(label, inFunc);
    }

    exports: ({label:'label'})
    Component.onDestruction: {
        if (cable) cable.destroy()
    }
}
