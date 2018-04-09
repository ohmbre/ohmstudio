import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import Qt.labs.folderlistmodel 2.1

import ohm.patch 1.0
import ohm.helpers 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 320
    height: 240
    title: "Ohm Studio"
    color: Style.patchBackgroundColor

    FontLoader { id: asapFont; source: "fonts/Asap-Medium.ttf" }

    Drawer {
        id: setup
        width: 0.33 * parent.width
        height: parent.height

        Button {
            anchors.horizontalCenter: setup.contentItem.horizontalCenter
            y: 50
            text: "New Patch"
            font.family: "Asap Medium"
            onClicked: {
                var c = Qt.createComponent("patch/Patch.qml");
                var newPatch = c.createObject(window, {name: "new patch", modules: [], cables: []});
                activePatch.setSource("patch/PatchView.qml", {patch: newPatch});
                setup.close();
            }
        }

        Button {
            anchors.horizontalCenter: setup.contentItem.horizontalCenter
            y: 100
            text: "Load Patch"
            font.family: "Asap Medium"
            onClicked: {
                loadFileDialog.visible = true;
            }
        }

        Button {
            anchors.horizontalCenter: setup.contentItem.horizontalCenter
            y: 150
            text: "Save Patch"
            font.family: "Asap Medium"
            onClicked: {
                saveFileDialog.visible = true;
            }
        }

        /*ListView {
            model: FolderListModel {
                nameFilters: ["*.qml"]
                folder: "modules"
            }
            delegate: Component { Text {text: fileName } }
        }*/

        FileDialog {
            id: loadFileDialog
            modality: visible ? Qt.WindowModal : Qt.NonModal
            folder: Constants.savedPatchDir
            onAccepted: {
                if (fileUrls.length === 0) return;
                if (window.loadPatchQML(fileUrl))
                    setup.close();
            }
        }

        FileDialog {
            id: saveFileDialog
            modality: visible ? Qt.WindowModal : Qt.NonModal
            folder: Constants.savedPatchDir
            onAccepted: {
                console.log(fileUrls);
            }
        }
    }

    function loadPatchQML(url) {
        try {
        var rawdata = Fn.readFile(url);
            var obj = Qt.createQmlObject(rawdata, window, url);
        } catch(err) {
            console.log(err);
            return false;
        }
    obj.importList = obj.parseImports(rawdata)
    activePatch.setSource("patch/PatchView.qml", {patch: obj});
        return true;
    }

    Loader {
        id: activePatch
        anchors.fill: parent
        onLoaded: console.log("patch loaded")
    }

    Patch {}

    Component.onCompleted: {
        if (!loadPatchQML(Constants.autoSavePath))
            setup.open();
    }
}
