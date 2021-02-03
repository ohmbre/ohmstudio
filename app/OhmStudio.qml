import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

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

    function xpct(pct) {
    return pct * globalWidth / 100;
    }

    function ypct(pct) {
    return pct * globalHeight / 100;
    }

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
            x: parent.w; y: 0; z: 3; width: 50; height: globalHeight
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
                onClicked: menu.submenu = menu.mainMenu
            }
        }

        OhmText {
            rotation: 90
            transformOrigin: Item.TopLeft
            x: overlay.w+12.5; y: 58
            Behavior on x { SmoothedAnimation { duration: 500 } }
            text: "Menu"
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
                sourceComponent: menu.mainMenu
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

            property Component audioOutMenu: Rectangle {
                height: globalHeight
                width: 200
                OhmChoiceBox {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    label: "Device"
                    model: audioOut.hw.availableDevs();
                    choice: audioOut.devId
                    onChosen: function(newId) {
                        audioOut.switchDev(newId);
                    }
                }
            }


            property Component mainMenu: Column {
                spacing: 10; width: 85; y: 20
                anchors.horizontalCenter: parent.horizontalCenter
                component MenuBtn : OhmButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                MenuBtn {
                    text: "New"
                    onClicked: {
                        patchCanvas.loadPatch('import ohm 1.0; Patch { modules: []; cables: [] }')
                        menu.close()
                    }
                }
                MenuBtn {
                    text: "Load"
                    onClicked: menu.submenu = menu.loadPatchMenu
                }
                MenuBtn {
                    text: "Save"
                    visible: activePatch.status === Loader.Ready
                    onClicked: {
                        if (menu.submenu != menu.savePatchMenu) {
                            menu.submenu = menu.savePatchMenu
                        } else {
                            menu.subItem.fileChosen(menu.subItem.saveFile)
                        }
                    }
                }
                MenuBtn {
                    text: "Audio Output"
                    onClicked: menu.submenu = menu.audioOutMenu
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
            var rawdata = FileIO.read('autosave.qml');
        if (!rawdata) rawdata = FileIO.read(':/app/default.qml')
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

