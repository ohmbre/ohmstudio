import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQml 2.2
import QtQml.Models 2.2
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

	function handlePinch(pinch) {
	    if (pinch.scale < pinch.previousScale) return;
	    var vp = patchView.contentItem.mapFromItem(patchView, 0, 0);
	    var vport = Qt.rect(vp.x, vp.y, patchView.width/pinch.scale, patchView.height/pinch.scale);
	    var visibleModules = [];
	    for (var i = 0; i < patch.modules.length; i++) {
		var mv = patch.modules[i].view;
		if (Fn.aContainsB(vport, Qt.rect(mv.x,mv.y,mv.width,mv.height)))
		    visibleModules.push(patch.modules[i]);
	    }
	    if (visibleModules.length == 1) {
		/*var module = visibleModules[0];
		var zoom = 160/module.view.radius;
		patchView.contentItem.scale = zoom;
		patchView.contentX = module.view.x/zoom;
		patchView.contentY = module.view.y/zoom;
		console.log(module.label);*/
	    }
	}

	onPinchFinished: handlePinch(pinch)

        MouseArea {
            anchors.fill: parent
	    id: pvArea
	    hoverEnabled: true
            anchors.centerIn: parent
            scrollGestureEnabled: false
            propagateComposedEvents: false
            onReleased: propagateComposedEvents = true

            onWheel: {
		var mp = pvArea.mapToItem(patchView, pvArea.mouseX, pvArea.mouseY);
		var oldZoom = patchView.contentItem.scale;
		var newZoom = oldZoom * (1 + wheel.angleDelta.y / 1200);
		//patchView.contentX += (mp.x - 160) * (newZoom - oldZoom);
		//patchView.contentY += (mp.y - 120) * (newZoom - oldZoom);
                patchView.contentItem.scale = newZoom;
		parent.handlePinch({scale: newZoom, previousScale: oldZoom});
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
                            var namespace = folderModel.folder.toString().replace(Qt.resolvedUrl('../..'),'');
                            while (namespace.indexOf("/") !== -1) namespace = namespace.replace('/','.');
                            var pos = moduleMenu.contentItem.mapToItem(patchView, 0, 0);
                            pos.x -= patchView.width/2; pos.y -= patchView.height/2;
                            patchView.patch.addModule(fileBaseName, namespace + " 1.0", pos.x, pos.y);
                            moduleMenu.close();
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
