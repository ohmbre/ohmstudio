import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Shapes 1.11

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


    property var globalWidth: 320
    property var globalScale: window.width / 320
    property var globalHeight: window.height/globalScale


    Rectangle {
        scale: globalScale
        transformOrigin: Item.TopLeft
        id: overlay
        width: globalWidth
        height: globalHeight
        z: 2
        color: 'transparent'
        property var w: menu.subItem.width
        Shape {
            x: overlay.w; y: 0; z: 3; width: 50; height: globalHeight
            Behavior on x { SmoothedAnimation { duration: 500 } }
            ShapePath {
                strokeWidth: 2
                strokeColor: 'black'
                fillColor: 'transparent'
                startX: 0; startY: 0
                pathElements: [
                    PathLine {x: 0; y: 50},
                    PathLine {x: -2; y: 50},
                    PathLine {x: 16; y: 50},
                    PathLine {x: 16; y: 90},
                    PathLine {x: -2; y: 90},
                    PathLine {x: 0; y: 90},
                    PathLine {x: 0; y: globalHeight}
                ]
            }
        }

        MouseArea {
            x: overlay.w
            Behavior on x { SmoothedAnimation { duration: 500 } }
            width: globalWidth - overlay.w
            Behavior on width { SmoothedAnimation { duration: 500 } }
            height: globalHeight
            enabled: menu.submenu != menu.emptyMenu
            onClicked: {
                menu.close()
            }
        }

        Rectangle {
            x: overlay.w; y: 50
            Behavior on x { SmoothedAnimation { duration: 500 } }
            width: 16; height: 40;
            color: 'white'
            MouseArea {
                anchors.fill: parent
                onClicked: menu.submenu = menu.patchMenu
            }
        }

        OhmText {
            rotation: 90
            transformOrigin: Item.TopLeft
            x: overlay.w+12.5; y: 58
            Behavior on x { SmoothedAnimation { duration: 500 } }
            text: "Patch"
            font.weight: Font.Bold
        }

        Rectangle {
            id: menu
            width: overlay.w
            Behavior on width { SmoothedAnimation { duration: 500 } }
            height: globalHeight
            Loader {
                anchors.right: parent.right
                id: activeChild
                sourceComponent: menu.patchMenu
            }
            property alias submenu: activeChild.sourceComponent
            property alias subItem: activeChild.item
            function close() {
                submenu = emptyMenu
            }


            property Component emptyMenu: Rectangle {
                height: globalHeight
                width: 0
            }

            property Component loadPatchMenu: OhmFileChoose {
                forLoading: true
                directory: 'patches'
                extension: 'qml'
                onFileChosen: function(fileURL) {
                    patchCanvas.loadPatch(FileIO.read(fileURL))
                    menu.close()
                }
            }

            property Component savePatchMenu: OhmFileChoose {
                forSaving: true
                directory: 'patches'
                extension: 'qml'
                onFileChosen: function(fileURL) {
                    activePatch.item.patch.saveTo(fileURL);
                    menu.close()
                }
            }

            property Component convertModuleMenu: ModuleConversion {
                width: 200
            }


            property Component patchMenu: Column {
                spacing: 10; width: 85; y: 20
                anchors.horizontalCenter: parent.horizontalCenter
                OhmButton {
                    text: "New"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        patchCanvas.loadPatch('import ohm 1.0; Patch { modules: []; cables: [] }')
                        menu.close()
                    }
                }
                OhmButton {
                    text: "Load"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: menu.submenu = menu.loadPatchMenu
                }
                OhmButton {
                    visible: activePatch.status === Loader.Ready
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Save"
                    onClicked: {
                        if (menu.submenu != menu.savePatchMenu) {
                            menu.submenu = menu.savePatchMenu
                        } else {
                            menu.subItem.fileChosen(menu.subItem.saveFile)
                        }
                    }
                }
                OhmButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Modularize"
                    onClicked: {
                        menu.submenu = menu.convertModuleMenu
                    }
                }
            }
        }
    }


    Item {
        id: patchCanvas
        width: globalWidth
        height: globalHeight
        scale: globalScale
        transformOrigin: Item.TopLeft
        z: 1

        function loadAutoSave() {
            var rawdata = readFile("file:autosave.qml");
            if (rawdata)
                loadPatch(rawdata, 'qrc:/app/autosave.qml')
        }

        function loadPatch(raw,url) {
            if (!url) url="dynamic"
            if (activePatch.item && activePatch.item.patch) {
                activePatch.item.patch.destroy()
            }
            try {
                var obj = Qt.createQmlObject(raw, window, url);
            } catch(err) {
                console.log("could not load ",url,":",err);
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
            loadAutoSave()
        }
    }
}

