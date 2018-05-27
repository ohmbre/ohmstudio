import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.3
import Qt.labs.folderlistmodel 2.1

import ohm.patch 1.0
import ohm.helpers 1.0
import ohm.ui 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 320
    height: 240
    title: "Ohm Studio"
    color: Style.patchBackgroundColor

    FontLoader { id: asapFont; source: "ui/fonts/Asap-Medium.ttf" }

    Drawer {
        id: setup
        width: 0.33 * parent.width
        height: parent.height
        background: Rectangle {
            implicitHeight: setup.height + border.width * 2
            implicitWidth: setup.width + border.width * 2
            x: -border.width
            y: -border.width

            color: Style.drawerColor
            border.width: 4
            border.color: Style.buttonBorderColor
        }

        Rectangle {
            width: parent.width + 1;
            height: 20
            color: Style.buttonBorderColor
            OhmText {
                anchors.fill: parent
                text: "Ω"
                color: Style.buttonTextColor
                font.weight: Font.Bold
                font.pixelSize: 18
            }
        }

        OhmButton {
            y: 50; x: parent.width - width + radius - 3
            text: "New Patch"
            onClicked: {
                var c = Qt.createComponent("patch/Patch.qml");
                var newPatch = c.createObject(window, {name: "new patch", modules: [], cables: []});
                activePatch.setSource("patch/PatchView.qml", {patch: newPatch});
                setup.close();
            }
        }

        OhmButton {
            y: 100; x: parent.width - width + radius - 3
            text: "Load Patch"
            onClicked: {
                loadFileDialog.visible = true;
            }
        }

        OhmButton {
            y: 150; x: parent.width - width + radius - 3
            visible: activePatch.status === Loader.Ready
            text: "Save Patch"
            onClicked: {
                saveFileDialog.visible = true;
            }
        }

        FileDialog {
            id: loadFileDialog
            modality: visible ? Qt.WindowModal : Qt.NonModal
            folder: Constants.savedPatchDir
            nameFilters: ["Patch files (*.qml)"]
            selectExisting: true
            sidebarVisible: false
            title: "Load Patch"
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
            nameFilters: ["Patch files (*.qml)"]
            selectExisting: false
            sidebarVisible: false
            title: "Save Patch"
            onAccepted: {
                if (fileUrls.length === 0) return;
                var fileName = fileUrl;
                activePatch.item.patch.saveTo(fileName);
                setup.close();
            }
        }
    }

    function loadPatchQML(url) {
        try {
        var rawdata = Fn.readFile(url);
            var obj = Qt.createQmlObject(rawdata, window, url);
        } catch(err) {
            console.error("could not load " + url + "\n" + err);
            return false;
        }
        obj.importList = obj.parseImports(rawdata)
        activePatch.setSource("patch/PatchView.qml", {patch: obj});
        return true;
    }

    Loader {
        id: activePatch
        objectName: "patchLoader"
        anchors.fill: parent
    }

    Component.onCompleted: {
        if (!loadPatchQML(Constants.autoSavePath))
            setup.open();
    }

}
