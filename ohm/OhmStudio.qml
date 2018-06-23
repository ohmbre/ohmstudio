import QtQuick 2.11
import QtQuick.Controls 2.4
import Qt.labs.folderlistmodel 2.2

import ohm.patch 1.0
import ohm.helpers 1.0
import ohm.ui 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 320
    height: 240
    //maximumWidth: 320
    //maximumHeight: 240
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
            implicitHeight: setup.height + border.width * 2
            implicitWidth: setup.width + border.width * 2
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
                var c = Qt.createComponent("patch/Patch.qml");
                var newPatch = c.createObject(window, {name: "new patch", modules: [], cables: []});
                if (activePatch.item) {
                    console.error('destroying active patch');
                    activePatch.item.patch.destroy()
                }
                activePatch.setSource("patch/PatchView.qml", {patch: newPatch});
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
            onFileChosen: function(fileURL) {
                activePatch.item.patch.saveTo(fileURL);
                saveFileChoose.close()
                setup.close()
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
        if (activePatch.item) {
            console.log('destroying active patch');
            activePatch.item.patch.destroy()
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
    
    onClosing: {
	console.error('main window closed');
    }
}

