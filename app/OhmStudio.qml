import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import Qt.labs.platform
import Qt.labs.settings

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

    Settings {
        id: settings
        property alias x: window.x
        property alias y: window.y
        property alias width: window.width
        property alias height: window.height
        property bool proTips: true
        property alias modrepo: repoUrl.text
    }
    
    property real globalWidth: 480
    property real globalScale: window.width / globalWidth
    property real globalHeight: window.height/globalScale

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
        
        Shape {
            x: menu.x + menu.width; y: 0; z: 3; width: 50; height: globalHeight
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
            x: menu.x + menu.width
            width: globalWidth - menu.width - menu.x
            Behavior on width { SmoothedAnimation { duration: 500 } }
            height: globalHeight
            enabled: menu.open
            onClicked: menu.open = false
        }

        Rectangle {
            x: menu.x + menu.width; y: 50
            width: 16; height: 40;
            color: 'white'
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    menu.page = mainMenu
                    menu.open = true
                }
            }
        }

        OhmText {
            rotation: 90
            transformOrigin: Item.TopLeft
            x: menu.x + menu.width + 12.5; y: 58
            text: "Menu"
            font.weight: Font.Bold
        }

        Rectangle {
            id: menu
            x: open ? 0 : -width
            width: 150
            Behavior on x { SmoothedAnimation { duration: 500 } }
            height: globalHeight
            property Item page: mainMenu
            property bool open: true
            
            Image {
                source: 'ui/icons/logo.svg'
                sourceSize.width: 80
                scale: 1./globalScale
                anchors.horizontalCenter: parent.horizontalCenter
            }

            
            Column {
                id: mainMenu
                anchors.fill: parent
                visible: menu.page == mainMenu
                topPadding: 90
                spacing: 10
                
                
                MenuBtn {
                    text: "New Patch"
                    onClicked: {
                        pView.newPatch()
                        menu.open = false
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
                    onClicked: menu.page = audioMenu
                }
                
                MenuBtn {
                    text: "Module Repo"
                    onClicked: menu.page = repoMenu
                }
                
                component MenuBtn : OhmButton {
                    anchors.horizontalCenter: parent.horizontalCenter
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
                        menu.open = false
                    }
                    onRejected: {
                        patchFile.close()
                        menu.open = false
                    }
                }
            }
            
            Rectangle {
                id: audioMenu
                visible: menu.page == audioMenu
                anchors.fill: parent
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        inChoice.focus = false
                        outChoice.focus = false
                        rateChoice.focus = false
                    }
                }   
                
                OhmChoiceBox {
                    id: outChoice
                    y: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    label: "Output"
                    font.pixelSize: 6                 
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
                    font.pixelSize: 6
                    model: AUDIO.availableDevs(false)
                    choice: AUDIO.inName
                    onChosen: function(newId) {
                        AUDIO.inName = newId;
                    }
                }

                OhmChoiceBox {
                    id: rateChoice
                    y: 110
                    anchors.horizontalCenter: parent.horizontalCenter
                    label: "Rate"
                    font.pixelSize: 6
                    model: [8000,11025,16000,22050,44100,48000,88200,96000,192000,352800,384000].map(i=>i.toString())
                    choice: AUDIO.sampleRate.toString()
                    onChosen: function(newRate) {
                        AUDIO.sampleRate = parseInt(newRate)
                    }
                }
            }
            
            Column {
                id: repoMenu
                visible: menu.page == repoMenu
                anchors.fill: parent
                topPadding: 50
                OhmText {
                    text: "Remote Repository"
                    font.pixelSize: 7
                    anchors.horizontalCenter: parent.horizontalCenter                    
                }
                TextEdit {
                    id: repoUrl
                    width: 100
                    font.pixelSize: 6
                    font.family: "Asap Medium"
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: 7
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
    
    Popup {
        id: proTips
        x: xpct(68)*globalScale; y: ypct(8)
        width: xpct(29); height: ypct(23)
        scale: globalScale; transformOrigin: Item.TopLeft
        visible: settings.proTips
        closePolicy: Popup.NoAutoClose	
        OhmButton {
            anchors.right: parent.right
            anchors.margins: 0
            width: xpct(1.8); height: ypct(2.4)
            font.family: "Asap Medium"
            font.pixelSize: 4
            text: "🗙"
            border: .5
            onClicked: {
                proTips.close()
                settings.proTips = false
            }
                
        }
            
        Column{ 
            width: parent.width
            OhmText { 
                width: parent.width
                font.pixelSize: 8; 
                font.family: "Asap SemiBold"
                horizontalAlignment: Text.AlignHCenter
                text: "How it's done"; 
            }
            OhmText { font.pixelSize: 6; text: "• tap '+' to add a modules"}
            OhmText { font.pixelSize: 6; text: "• tap a module to show all jacks"}
            OhmText { font.pixelSize: 6; text: "• drag/drop between jacks to create cables" }
            OhmText { font.pixelSize: 6; text: "• double tap a module to tweak its controls" }
            OhmText { font.pixelSize: 6; text: "• long press & hold a module to delete it" }
            OhmText { font.pixelSize: 6; text: "• pinch/scroll to zoom" }
            OhmText { font.pixelSize: 6; text: "• drag background canvas to pan" }
            OhmText { font.pixelSize: 6; text: "• Draw a cable to an 'Audio Out' module to hear"}
        }
    }

    
}

