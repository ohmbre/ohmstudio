pragma Singleton
import QtQuick 2.11

QtObject {
    property QtObject jack: QtObject {
        property string dirIn: "inp"
        property string dirOut: "out"
    }
    property string autoSavePath: 'file:./patches/autosave.qml'
    property string savedPatchDir: 'file:./patches'
}
