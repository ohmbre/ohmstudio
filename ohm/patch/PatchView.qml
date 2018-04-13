import QtQuick 2.9
import QtQuick.Controls 2.3

import QtQml 2.2
import Qt.labs.folderlistmodel 2.2

import ohm 1.0
import ohm.module 1.0
import ohm.cable 1.0
import ohm.ui 1.0
import ohm.helpers 1.0

Flickable {
    id: patchView
    property Patch patch

    anchors.fill: parent
    contentWidth: 1600; contentHeight: 1200
    contentX: contentWidth/2 - width/2
    contentY: contentHeight/2 - height/2
    flickableDirection: Flickable.HorizontalAndVerticalFlick
    scale: 1
    //maximumFlickVelocity: 10

    Repeater {
        model: patch.modules
        ModuleView {
            module: modelData
        }
    }



    Repeater {
        model: patch.cables
        CableView {
           cable: modelData
        }
    }

    PinchArea {
        anchors.fill: parent
        pinch.target: patchView.contentItem
        pinch.minimumScale: 0.1
        pinch.maximumScale: 5
        pinch.dragAxis: Pinch.XAndYAxis

        MouseArea {
            anchors.fill: parent
            anchors.centerIn: parent
            scrollGestureEnabled: false
            propagateComposedEvents: true
            //preventStealing: true
            onWheel: {
                patchView.contentItem.scale += patchView.contentItem.scale * wheel.angleDelta.y / 120 / 10;
            }
            onPressAndHold: moduleMenu.popup()
        }
    }


    OhmPopup {
        id: moduleMenu
        title: "Add Module"
        width: 95
        contents:  ListView {
            id: moduleList
            width: moduleMenu.width
            height: (count-1) * 14
            keyNavigationEnabled: true
            model: FolderListModel {
                id: folderModel
                folder: '../module'
                rootFolder: '../module'
                nameFilters: ["*?Module.qml",".."]
                showDirs: true
                showDirsFirst: true
                showHidden: true
                showDotAndDotDot: true
                showFiles: true
            }
            delegate: OhmText {
                width: moduleMenu.width
                height: fileName == "." ? 0 : 14
                visible: fileName != "."
                text: fileName.replace(/\.qml$/,'') + (fileIsDir ? " ▶" : "  ")
                color: "black"
                horizontalAlignment: Text.AlignRight
                padding: 2
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (fileIsDir) {
                            if (fileName == "..") folderModel.folder = folderModel.parentFolder;
                            else folderModel.folder += "/" + fileName;
                        } else {
                            var mObj = Qt.createQmlObject(Fn.readFile(fileURL), patchView.patch, fileURL);
                            var namespace = folderModel.folder.toString().replace(Qt.resolvedUrl('../..'),'');
                            while (namespace.indexOf("/") !== -1) namespace = namespace.replace('/','.');
                            patchView.patch.addModule(mObj, namespace + " 1.0");
                            moduleMenu.close();


                            //var pos = moduleMenu.contentItem.mapToItem(patchView.contentItem, 0,0);
                            //mObj.x = pos.x - patchView.contentItem.width/2;
                            //mObj.y = pos.y - patchView.contentItem.height/2;

                        }
                    }
                }
            }
            highlight: Rectangle {
                color: Style.menuLitColor
            }
            clip: true
            onCountChanged: moduleMenu.height = (count-1) * 14 + 13
        }

    }

    OhmPopup {
        id: delModuleMenu
        title: "Delete?"
        height: 45
        width: 39
        contents: OhmButton {
            x: Fn.centerInX(this,delModuleMenu)
            y: Fn.centerInY(this,delModuleMenu.body)
            imageUrl: "../ui/icons/delete.svg"
            onClicked: {
                patch.deleteModule(delModuleMenu.candidate);
                delModuleMenu.close();
            }
        }
        property Module candidate
    }

    function confirmDeleteModule(module) {
        delModuleMenu.candidate = module;
        delModuleMenu.popup();
    }

    Timer {
        interval: 3000; running: true; repeat: true
        onTriggered: {
            if (patch.cueAutoSave)
                patch.autosave();
        }
    }

    CableDragView {id: childCableDragView; }
    property alias cableDragView: childCableDragView

    Component.onCompleted: {
        patch.view = patchView;
    }
}



