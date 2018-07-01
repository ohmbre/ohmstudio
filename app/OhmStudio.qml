import QtQuick 2.11
import QtQuick.Controls 2.4

ApplicationWindow {
    id: window
    visible: true
    width: 320
    height: 240
    minimumWidth: 320
    minimumHeight: 240

    title: "Ohm Studio"
    color: Style.patchBackgroundColor

    FontLoader { id: asapFont; source: "ui/fonts/Asap-Medium.ttf" }

    OhmEngine {	id: engine  }

    Drawer {
        id: setup
        width: 0.33 * parent.width
        Behavior on width { SmoothedAnimation { velocity: 300 } }
        height: parent.height
        background: Rectangle {
            height: setup.height + border.width * 2
            width: setup.width + border.width * 2
            x: -border.width
            y: -border.width

            color: Style.drawerColor
            border.width: 4
            border.color: Style.buttonBorderColor
        }

        Rectangle {
            id: header
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
		loadPatch('import ohm 1.0; Patch { modules: []; cables: [] }')
                setup.close();
            }
        }

        OhmButton {
            y: 100; x: parent.width - width + radius - 3
            text: "Load Patch"
            onClicked: {
                setup.width = 0.8*window.width;
                saveFileChoose.close();
                loadFileChoose.open();
            }
        }

        OhmButton {
            y: 150; x: parent.width - width + radius - 3
            visible: activePatch.status === Loader.Ready
            text: "Save Patch"
            onClicked: {
                if (!saveFileChoose.visible) {
                    setup.width = 0.8*window.width;
                    loadFileChoose.close();
                    saveFileChoose.open();
                    label.color = Style.fileChooseLitColor
                } else {
                    saveFileChoose.fileChosen(saveFileChoose.saveFile)
                    label.color = Style.buttonTextColor
                }
            }
        }

        onClosed: function() {
            loadFileChoose.close()
            saveFileChoose.close()
            setup.width = .33 * setup.parent.width;
        }

        OhmFileChoose {
            id: loadFileChoose
            forLoading: true
	    directory: 'file:./patches'
	    extension: 'qml'
            onFileChosen: function(fileURL) {
                if (window.loadPatchQML(fileURL)) {
                    loadFileChoose.close()
                    setup.close();
                }
            }
        }

        OhmFileChoose {
            id: saveFileChoose
            forSaving: true
	    directory: 'file:./patches'
	    extension: 'qml'
            onFileChosen: function(fileURL) {
                activePatch.item.patch.saveTo(fileURL);
                saveFileChoose.close()
                setup.close()
            }
        }
    }
    
    function loadPatchQML(url) {
        var rawdata = Fn.readFile(url);
	if (!rawdata) return false
	return loadPatch(rawdata)
    }

    function loadPatch(raw,url) {
	if (!url) url="dynamic"
	if (activePatch.item) {
            console.log('destroying active patch');
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
        if (!loadPatchQML(Constants.autoSavePath))
            setup.open();
    }

    onClosing: {
        console.error('main window closed');
    }
}

