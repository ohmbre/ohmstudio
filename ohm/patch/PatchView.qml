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

Item {
    id: patchView
    property Patch patch
    width: 320
    height: 240
    
    Item {
	id: content
	width: 1600
	height: 1200
	x: (parent.width-width)/2
	y: (parent.height-height)/2
	transform: Scale {
	    id: scaler
	    origin.x: width/2
	    origin.y: height/2
	    xScale: zoom
	    yScale: zoom
	    property real zoom: 1.0
	    property real max: 10
	    property real min: 0.2
	    function zoomContent(zoomDelta, centerX, centerY) {
		var oldZoom = zoom;
		zoom = Math.min(Math.max(zoom*(1+zoomDelta),min),max);
                content.x += (patchView.width/2-centerX)*(zoom-oldZoom);
                content.y += (patchView.height/2-centerY)*(zoom-oldZoom);
                var topleft = content.mapFromItem(patchView,0,0);
                if (topleft.x < 0) content.x += topleft.x*zoom;
                if (topleft.y < 0) content.y += topleft.y*zoom;
                var bottright = content.mapFromItem(patchView,patchView.width,patchView.height);
                if (bottright.x > content.width) content.x -= (content.width-bottright.x)*zoom;
                if (bottright.y > content.height) content.y -= (content.height-bottright.y)*zoom;
	    }
	}

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
	    
	    onPinchUpdated: {
                var dz = pinch.scale-pinch.previousScale;
		scaler.zoomContent(dz, pinch.startCenter.x, pinch.startCenter.y);
            }

	    onPinchFinished: handlePinch(pinch)

            MouseArea {
		id: dragArea
		hoverEnabled: true
		anchors.fill: parent
		drag.target: content
		drag.filterChildren: true
		drag.maximumX: patchView.width * (scaler.zoom-1) / (2*scaler.min)
                drag.maximumY: patchView.height * (scaler.zoom-1) / (2*scaler.min)
                drag.minimumX: -patchView.width * (scaler.zoom+0.6) / (2*scaler.min)
                drag.minimumY: -patchView.height * (scaler.zoom+0.6) / (2*scaler.min)
		propagateComposedEvents: false
		onReleased: propagateComposedEvents = true

		onWheel: {
		    scaler.zoomContent(wheel.angleDelta.y / 2400, mouseX, mouseY);
		    //parent.handlePinch({scale: newZoom, previousScale: oldZoom});
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
				var ns = folderModel.folder.toString();
				ns = ns.replace(Qt.resolvedUrl('../..'), '');
				while (ns.indexOf("/") !== -1) ns = ns.replace('/','.');
				var pos = moduleMenu.contentItem.mapToItem(patchView, 0, 0);
				pos.x -= patchView.width/2; pos.y -= patchView.height/2;
				patchView.patch.addModule(fileBaseName, ns + " 1.0", pos.x, pos.y);
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
    }

    property alias contentItem: content
    property alias cableDragView: childCableDragView

    Component.onCompleted: {
        patch.view = patchView;
    }

}
