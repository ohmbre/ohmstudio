import QtQuick 2.11
import QtQuick.Controls 2.4

import "qrc:/app/engine/ohm.mjs" as OhmEngine

ApplicationWindow {
    id: window
    visible: true
    flags: Qt.Window
    width: 1000
    height: 1000
    minimumWidth: 320
    minimumHeight: 240

    title: "Ohm Studio"
    color: Style.patchBackgroundColor

    Drawer {
        id: setup
        property real extension: (saveFileChoose.open || loadFileChoose.open || optionChoose.open)
        width: 0.3*(1 + extension) * overlay.width * overlay.scale
        height: overlay.height * overlay.scale
        dragMargin: 15*overlay.scale

        Behavior on width { SmoothedAnimation { velocity: 500 } }

        background: Rectangle {
            height: setup.height + border.width * 2
            width: setup.width + border.width * 2
            x: -border.width
            y: -border.width

            color: Style.drawerColor
            border.width: 4*overlay.scale
            border.color: Style.buttonBorderColor
        }

        Rectangle {
            id: header
            width: parent.width + 1;
            height: 18 * overlay.scale
            color: Style.buttonBorderColor
            Image {
                source: "qrc:/app/ui/icons/logo.svg"
                x: Fn.centerInX(this,parent)
                y: Fn.centerInY(this,parent)
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
                optionChoose.open = false
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
                    optionChoose.open = false
                } else {
                    saveFileChoose.fileChosen(saveFileChoose.saveFile)
                }
            }
        }

        OhmButton {
            id: optionBtn
            width: saveBtn.width
            scale: overlay.scale
            y: 200*overlay.scale; x: parent.width - width + radius - 8*overlay.scale
            text: "Options"
            onClicked: {
                if (!optionChoose.open) {
                    loadFileChoose.open = false;
                    saveFileChoose.open = false;
                    optionChoose.open = true;
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

        OhmOptionChoose {
            id: optionChoose
            scale: overlay.scale
        }
    }



    Item {
        id: overlay
        width: 320
        height: width * window.height / window.width
        scale: window.width / width
        transformOrigin: Item.TopLeft
        FontLoader { id: asapFont; source: "qrc:/app/ui/fonts/Asap-Medium.ttf" }

        Engine {
            id: engine
        }

        function loadPatchQML(url) {
            var rawdata = Fn.readFile(url);
            if (!rawdata) return false
            return loadPatch(rawdata)
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
            loadPatchQML(Constants.autoSavePath)
            let options = Fn.readFile(Constants.optionsPath)
            options = options ? JSON.parse(options) : {}
            if ("audioOut" in options)
                HWIO.outName = options["audioOut"]
            else
                HWIO.resetOut()
            setup.open()
        }
    }
}

