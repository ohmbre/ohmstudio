import ohm 1.0
import QtQuick

Model {

    id: cable
    property var inp
    property var out

    Component.onDestruction: {
        if (inp && inp.cableRemoved) inp.cableRemoved();
        if (out && out.cableRemoved) out.cableRemoved(cable);
    }

    Component.onCompleted: {
        if (out) out = out
        if (inp) inp = inp

        if (out) out.cableAdded(cable);
        if (inp) inp.cableAdded(cable);

        if (out && inp && inp.updateInFunc) out.outFuncUpdated.connect(inp.updateInFunc);
        
        parent.cablesChanged();
        
    }

}
