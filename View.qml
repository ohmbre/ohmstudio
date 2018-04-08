import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2

import "Helpers.js" as F


ApplicationWindow {
    id: window
    visible: true
    width: 640
    height: 480
    title: "Ohm Studio"
    color: Style.patchBackgroundColor

    FontLoader { id: asapFont; source: "fonts/Asap-Medium.ttf" }

    Drawer {
        id: setup
        width: 0.33 * parent.width
        height: parent.height

        Button {
            anchors.horizontalCenter: setup.contentItem.horizontalCenter
            y: 100
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
            y: 200
            text: "Load Patch"
            font.family: "Asap Medium"
            onClicked: {
                loadFileDialog.visible = true;
            }
        }

        Button {
            anchors.horizontalCenter: setup.contentItem.horizontalCenter
            y: 300
            text: "Save Patch"
            font.family: "Asap Medium"
            onClicked: {
                saveFileDialog.visible = true;
            }
        }

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

    property string importHeader: "import 'qrc:/'; import 'qrc:/module'; import 'qrc:/module/clock'; import 'qrc:/module/envelope'; import 'qrc:/module/sequencer'; import 'qrc:/module/hw/audio'; import 'qrc:/cable'; import 'qrc:/patch'; import 'qrc:/module/osc'; import 'qrc:/module/cv'; import 'qrc:/jack'; import 'qrc:/jack/in'; import 'qrc:/module/vca';  import 'qrc:/jack/out'; import 'qrc:/jack/out/gate'; "

    function loadPatchQML(url) {
        try {
            var data = Qt.createQmlObject(importHeader + F.readFile(url), window, url);
            activePatch.setSource("patch/PatchView.qml", {patch: data});
        } catch(err) {
            console.log(err);
            return false;
        }
        return true;
    }

    Loader {
        id: activePatch
        anchors.fill: parent
        onLoaded: console.log("active patch loaded")
    }

    Component.onCompleted: {
        if (!loadPatchQML(Constants.autoSavePath))
            setup.open();
    }
}
