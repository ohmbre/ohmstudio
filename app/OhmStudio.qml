import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import Qt.labs.platform

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

            property Component audioMenu: Rectangle {
                
                height: globalHeight
                width: 200
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        inChoice.focus = false
                        outChoice.focus = false
                    }
                }   
                
                OhmChoiceBox {
                    id: outChoice
                    y: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    label: "Output"
                    model: AUDIO.availableDevs(true)
                    choice: AUDIO.outName
                    onChosen: function(newId) {
                        AUDIO.outName = newId;
                    }
                }

                OhmChoiceBox {
                    id: inChoice
                    y: 80
                    anchors.horizontalCenter: parent.horizontalCenter
                    label: "Input"
                    model: AUDIO.availableDevs(false)
                    choice: AUDIO.inName
                    onChosen: function(newId) {
                        AUDIO.inName = newId;
                    }
                }
                
                
                OhmChoiceBox {
                    y: 110
                    anchors.horizontalCenter: parent.horizontalCenter
                    label: "Rate"
                    model: [8000,11025,16000,22050,44100,48000,88200,96000,192000,352800,384000].map(i=>i.toString())
                    choice: AUDIO.sampleRate.toString()
                    onChosen: function(newRate) {
                        AUDIO.sampleRate = parseInt(newRate)
                    }
                }
            }

            FileDialog {
                id: patchFile
                folder: StandardPaths.writableLocation(StandardPaths.AppDataLocation)+'/patches'
                defaultSuffix: 'json'
                property var callback: (file)=>{}
                nameFilters: ['JSON files (*.json)']
                selectedNameFilter.index: 1
                onAccepted: {
                    callback(file)
                    patchFile.close()                    
                    menu.close()
                }
                onRejected: {
                    patchFile.close()
                    menu.close()
                }
            }

            property Component mainMenu: Column {
                spacing: 10; width: 85; y: 20
                anchors.horizontalCenter: parent.horizontalCenter
                component MenuBtn : OhmButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                MenuBtn {
                    text: "New Patch"
                    onClicked: {
                        pView.newPatch()
                        menu.close()
                    }
                }
                MenuBtn {
                    text: "Open Patch"
                    onClicked: {
                        patchFile.fileMode = FileDialog.OpenFile
                        patchFile.callback = (file) => {
                            pView.newPatch()
                            loadPatch(pView.patch, file)
                        }
                        patchFile.open()
                    }
                }
                MenuBtn {
                    text: "Merge Patch"
                    onClicked: {
                        patchFile.fileMode = FileDialog.OpenFile
                        patchFile.callback = (file) => {
                            loadPatch(pView.patch, file)
                        }
                        patchFile.open()
                    }
                }
                MenuBtn {
                    text: "Save Patch"
                    onClicked: {
                        patchFile.fileMode = FileDialog.SaveFile
                        patchFile.callback = (file) => {
                            savePatch(pView.patch, file)
                        }
                        patchFile.open()
                    }
                }
                MenuBtn {
                    text: "Audio Devices"
                    onClicked: menu.submenu = menu.audioMenu
                }
            }
        }
    }

    PatchView {
      id: pView
      width: xpct(100)
      height: ypct(100)
      scale: globalScale
      transformOrigin: Item.TopLeft
      z: 1
    }
    

    
}

