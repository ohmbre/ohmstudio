pragma Singleton
import QtQuick 2.10

QtObject {
    property QtObject jack: QtObject {
        property string dirIn: "inp"
        property string dirOut: "out"
    }
    property string autoSavePath: 'file:./autosave.qml'
    property string savedPatchDir: 'file:./'
}
