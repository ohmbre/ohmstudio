pragma Singleton
import QtQuick 2.11

QtObject {
    property QtObject jack: QtObject {
        property string dirIn: "inp"
        property string dirOut: "out"
    }
    property string savedPatchDir: 'file:./patches'
    property string autoSavePath: savedPatchDir + '/autosave.qml'
}
