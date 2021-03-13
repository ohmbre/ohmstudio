import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import "qrc:/app/util.mjs" as Util

ApplicationWindow {
    id: window
    visible: true
    width: 1280
    height: 960
    flags: Qt.Window
    title: "Ohm Studio"
    color: 'white'
    FontLoader { id: asapMedium; source: "qrc:/app/ui/fonts/Asap-Medium.ttf" }
    FontLoader { id: asapSemiBold; source: "qrc:/app/ui/fonts/Asap-SemiBold.ttf" }
    font.family: asapMedium.name


    property var globalWidth: 480
    property var globalScale: window.width / globalWidth
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
                startX: -1; startY: 0
                pathElements: [
                    PathLine {x: -1; y: 50},
                    PathLine {x: -3; y: 50},
                    PathLine {x: 16; y: 50},
                    PathLine {x: 16; y: 90},
                    PathLine {x: -3; y: 90},
                    PathLine {x: -1; y: 90},
                    PathLine {x: -1; y: globalHeight}
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
                    patchCanvas.loadPatch(MAESTRO.read(fileURL))
                    menu.close()
                }
            }

            property Component savePatchMenu: OhmFileChoose {
                forSaving: true
                directory: 'patches'
                extension: 'qml'
                onFileChosen: function(fileURL) {
                    pView.patch.saveTo(fileURL);
                    menu.close()
                }
            }

            property Component audioOutMenu: Rectangle {
                height: globalHeight
                width: 200
                OhmChoiceBox {
                    y: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    label: "Device"
                    model: AUDIO_OUT.availableDevs()
                    choice: AUDIO_OUT.name
                    onChosen: function(newId) {
                        AUDIO_OUT.name = newId;
                    }
                }

                OhmChoiceBox {
                    y: 80
                    anchors.horizontalCenter: parent.horizontalCenter
                    label: "Rate"
                    model: [8000,11025,16000,22050,44100,48000,88200,96000,192000,352800,384000].map(i=>i.toString())
                    choice: AUDIO_OUT.sampleRate.toString()
                    onChosen: function(newRate) {
                        AUDIO_OUT.sampleRate = parseInt(newRate)
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
                        patchCanvas.loadPatch('Patch { modules: []; cables: [] }')
                        menu.close()
                    }
                }
                MenuBtn {
                    text: "Load"
                    onClicked: menu.submenu = menu.loadPatchMenu
                }
                MenuBtn {
                    text: "Save"
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
            var rawdata = MAESTRO.read('autosave.qml');
            if (!rawdata) rawdata = MAESTRO.read(':/app/default.qml')
            if (rawdata)
                loadPatch(rawdata, 'qrc:/app/autosave.qml')

        }

        function loadPatch(raw,url) {
            try { 
                pView.patch = Qt.createQmlObject(raw, pView, url || "dynamic");
                autoSaveTimer.start()
            } 
            catch(err) {
                console.log("could not load ",url || "dynamic",":",err);
            }            
        }

        PatchView {
            id: pView
        }

        Timer {
            id: autoSaveTimer
            interval: 2000; running: false; repeat: true
            property var lastSave: ''
            onTriggered: {
                const qml = pView.patch.toQML();
                if (qml !== lastSave) {
                    MAESTRO.write('autosave.qml', qml)
                    lastSave = qml;
                }
            }
        }

        Component.onCompleted: {
            loadAutoSave()
        }
    }
    

}

