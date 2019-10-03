import QtQuick 2.11
import QtQuick.Controls 2.4

import "qrc:/app/util.mjs" as Util

ApplicationWindow {
    id: window
    visible: true
    flags: Qt.Window
    width: 1280
    height: 960

    title: "Ohm Studio"
    color: 'white'
    FontLoader { id: asapMedium; source: "qrc:/app/ui/fonts/Asap-Medium.ttf" }
    FontLoader { id: asapSemiBold; source: "qrc:/app/ui/fonts/Asap-SemiBold.ttf" }
    font.family: asapMedium.name


    Drawer {
        id: setup
        property real extension: (saveFileChoose.open || loadFileChoose.open)
        width: 0.3*(1 + extension) * overlay.width * overlay.scale
        height: overlay.height * overlay.scale
        dragMargin: 15*overlay.scale

        Behavior on extension { SmoothedAnimation { duration: 1000; velocity: -1 } }

        background: Rectangle {
            height: setup.height + border.width * 2
            width: setup.width + border.width * 2
            x: -border.width
            y: -border.width

            color: 'white'
            border.width: 4*overlay.scale
            border.color: 'black'
        }

        Rectangle {
            id: header
            width: parent.width + 1;
            height: 18 * overlay.scale
            color: 'black'
            Image {
                source: "qrc:/app/ui/icons/logo.svg"
                x: centerInX(this,parent)
                y: centerInY(this,parent)
                mipmap: true
                height: parent.height*.8
                width: parent.height*.8
            }
        }

        onClosed: {
            saveFileChoose.open = false
            loadFileChoose.open = false
        }

        OhmButton {
            scale: overlay.scale
            y: 50*overlay.scale; x: parent.width - width + radius - 8*overlay.scale
            text: "New Patch"
            onClicked: {
                overlay.loadPatch('import ohm 1.0; Patch { modules: []; cables: [] }')
                setup.close();
            }
        }

        OhmButton {
            id: loadBtn
            scale: overlay.scale
            y: 100*overlay.scale; x: parent.width - width + radius - 8*overlay.scale
            text: "Load Patch"
            onClicked: {
                saveFileChoose.open = false
                loadFileChoose.open = true
            }
        }

        OhmButton {
            id: saveBtn
            scale: overlay.scale
            y: 150*overlay.scale; x: parent.width - width + radius - 8*overlay.scale
            visible: activePatch.status === Loader.Ready
            text: "Save Patch"
            onClicked: {
                if (!saveFileChoose.open) {
                    loadFileChoose.open = false;
                    saveFileChoose.open = true;
                } else {
                    saveFileChoose.fileChosen(saveFileChoose.saveFile)
                }
            }
        }

        OhmFileChoose {
            id: loadFileChoose
            scale: overlay.scale
            forLoading: true
            directory: 'patches'
            extension: 'qml'
            onFileChosen: function(fileURL) {
                if (overlay.loadPatchQML(fileURL))
                    setup.close()
            }
        }

        OhmFileChoose {
            id: saveFileChoose
            scale: overlay.scale
            forSaving: true
            directory: 'patches'
            extension: 'qml'
            onFileChosen: function(fileURL) {
                activePatch.item.patch.saveTo(fileURL);
                setup.close()
            }
        }
    }

    property alias globalScale: overlay.scale

    Item {
        id: overlay
        width: 320
        height: width * window.height / window.width
        scale: window.width / width
        transformOrigin: Item.TopLeft

        function loadPatchQML(url) {
            var rawdata = readFile(url);
            if (!rawdata) return false
            return loadPatch(rawdata, url)
        }

        function loadPatch(raw,url) {
            if (!url) url="dynamic"
            if (activePatch.item) {
                activePatch.item.patch.destroy()
            }
            try {
                var obj = Qt.createQmlObject(raw, window, url);
            } catch(err) {
                console.error("could not load ",url,":",err);
                return false;
            }
            activePatch.setSource("PatchView.qml", {patch: obj});
            return true;
        }

        Loader {
            id: activePatch
            objectName: "patchLoader"
            anchors.fill: parent
        }

        Component.onCompleted: {
            loadPatchQML("patches/autosave.qml")
            setup.open()
        }
    }
}

