import QtQuick 2.10
import QtQuick.Controls 2.2
import Qt.labs.folderlistmodel 2.2

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
                loadFileDialog.open();
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

        Rectangle {
            id: loadFileDialog
            visible: false
            opacity: 0
            width: setup.width*0.65;
            Behavior on opacity { NumberAnimation { duration: 700; easing.type: Easing.InOutQuad }}
            height: window.height*0.8;
            color: Style.fileChooseBgColor
            x:15
            y: header.height+13
            ListView {
                id: fileChoose
                anchors.fill: parent
                keyNavigationEnabled: true
                highlight: Rectangle { color: Style.fileChooseLitColor; radius: 7 }
                focus: loadFileDialog.visible
                model: FolderListModel {
                    id: chooseFileModel
                    folder: '../patches'
                    rootFolder: '../patches'
                    nameFilters: ["*.qml",".."]
                    showDirs: true
                    showDirsFirst: true
                    showHidden: false
                    showDotAndDotDot: true
                    showFiles: true
                }
                delegate: OhmText {
                    leftPadding: 5
                    rightPadding:5
                    topPadding: 2
                    bottomPadding: 2
                    text: fileName
                    color: Style.fileChooseTextColor
                    width: parent.width
                    horizontalAlignment: Text.AlignLeft
                    MouseArea {
                        anchors.fill: parent
                        onClicked: fileChoose.currentIndex = index
                        onDoubleClicked: {
                            if (fileIsDir) {
                                if (fileName == '..') chooseFileModel.folder = chooseFileModel.folder
                                else chooseFileModel.folder += '/' + fileName;
                            } else {
                                if (window.loadPatchQML(fileURL))
                                    setup.close();
                            }
                        }
                    }
                }
                header: Rectangle {
                    width: parent.width
                    height:17
                    OhmText {
                        text: "Patch File"
                        color: Style.fileChooseTextColor
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        padding: 2
                        leftPadding: 4
                        horizontalAlignment: Text.AlignLeft
                    }
                    OhmText {
                        width: parent.width
                        text: "Saved"
                        color: Style.fileChooseTextColor
                        font.weight: Font.Bold
                        padding: 2
                        rightPadding: 4
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignRight
                    }
                    color: Style.buttonBorderColor
                }
            }

            function open() {
                setup.width = 0.8*window.width;
                loadFileDialog.visible = true;
                loadFileDialog.opacity = 1.0;
            }
            /*folder: Constants.savedPatchDir
            nameFilters: ["Patch files (*.qml)"]
            title: "Load Patch"
            onAccepted: {
                if (fileUrls.length === 0) return;
                if (window.loadPatchQML(fileUrl))
                    setup.close();
            }*/
        }

        Rectangle {
            id: saveFileDialog
            visible: false
            /*folder: Constants.savedPatchDir
            nameFilters: ["Patch files (*.qml)"]
            title: "Save Patch"
            onAccepted: {
                if (fileUrls.length === 0) return;
                var fileName = fileUrl;
                activePatch.item.patch.saveTo(fileName);
                setup.close();
            }*/
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

}
