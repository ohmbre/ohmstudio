import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQml 2.11

Item {
    id: pView
    property Patch patch
    width: 320
    height: 240

    Item {
        id: content
        width: 1600
        height: 1200
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        ParallelAnimation {
            id: zoomPanAnim
            running: false
            NumberAnimation {id: xAnim; property: 'x'; target: content; duration: 400}
            NumberAnimation {id: yAnim; property: 'y'; target: content; duration: 400}
            NumberAnimation {property: 'zoom'; target: scaler; duration: 400; to: scaler.max}
        }
        onXChanged: {
            var topleft = content.mapFromItem(pView,0,0);
            var bottright = content.mapFromItem(pView,pView.width,pView.height);
            if (topleft.x < 0) content.x += topleft.x*scaler.zoom;
            else if (bottright.x > content.width) content.x -= (content.width-bottright.x)*scaler.zoom;
        }
        onYChanged: {
            var topleft = content.mapFromItem(pView,0,0);
            var bottright = content.mapFromItem(pView,pView.width,pView.height);
            if (topleft.y < 0) content.y += topleft.y*scaler.zoom;
            else if (bottright.y > content.height) content.y -= (content.height-bottright.y)*scaler.zoom;
        }

        transform: Scale {
            id: scaler
            origin.x: 0
            origin.y: 0
            xScale: zoom
            yScale: zoom
            property real zoom: 1.0
            property real max: 10
            property real min: 0.5

            function zoomContent(zoomDelta, center) {
                if (zoomPanAnim.running) return;
                var oldZoom = zoom;
                var newZoom = zoom * (1 + zoomDelta);
                if (newZoom < min || newZoom > max) return;
                zoom = newZoom;
                content.x += center.x*(oldZoom-zoom);
                content.y += center.y*(oldZoom-zoom);
                if (zoom > 3.5 && zoomDelta > 0)
                    Fn.forEach(patch.modules, function(m) {
                        if (m.view.contains(content.mapToItem(m.view, center.x, center.y))) {
                            scaler.max = Math.min(pView.width/m.view.width, pView.height/m.view.height);
                            xAnim.to = -(m.view.x + m.view.width/2)*scaler.max + pView.width/2;
                            yAnim.to = -(m.view.y + m.view.height/2 + 2)*scaler.max + pView.height/2
                            zoomPanAnim.start();
                            m.view.innerModule.state = "controlMode";
                            return -1; // break
                        }
                    });
                else if (zoomDelta <= -0.015)
                    Fn.forEach(patch.modules, function(m) {
                        if (m.view.innerModule.state == "controlMode" && !m.view.innerModule.controlAnim.running) {
                            m.view.innerModule.state = "patchMode";
                            return -1;
                        }
                    });
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
            onPinchUpdated: scaler.zoomContent(pinch.scale-pinch.previousScale,
                                               Qt.point(pinch.startCenter.x, pinch.startCenter.y))
            MouseArea {
                id: mousePinch
                hoverEnabled: true
                anchors.fill: parent
                drag.target: content
                drag.filterChildren: true
                drag.threshold: 1
                propagateComposedEvents: false
                onReleased: propagateComposedEvents = true
                onWheel: scaler.zoomContent(wheel.angleDelta.y / 3200, Qt.point(wheel.x, wheel.y))
                onPressAndHold: function(mouse) {
		    mMenu.popOrigin = Qt.point(mouse.x,mouse.y)
		    mMenu.popup()
		}
            }
        }



        OhmPopup {
            id: mMenu
            title: "Add Module"
            width: 95
	    scale: window.width / overlay.width * .7
	    transformOrigin: Item.TopLeft
	    property point popOrigin: Qt.point(content.width/2, content.height/2)
	    property string folder: 'modules'
            contents:  ListView {
                id: moduleList
                width: mMenu.width
                height: model.length * 14
                keyNavigationEnabled: true
                model: FileIO.listDir(mMenu.folder,"*Module.qml")
                delegate: OhmText {
		    
                    width: mMenu.width
                    height: 14
		    property bool isDir: leaf.slice(-4) != '.qml'
		    property var parts: modelData.split('/')
		    property string leaf: parts[parts.length-1]
		    property string stem: parts.slice(0,-1).join('/')
                    text: isDir ? leaf : leaf.slice(0,-10)
                    color: "black"
                    horizontalAlignment: Text.AlignRight
                    padding: 2
		    rightPadding: 14
		    Image {
			source: 'ui/icons/arrow.svg'
			width: 11
			height: 5
			visible: isDir
			horizontalAlignment: Text.AlignRight
			y: 5.5
			x: parent.width - 12
		    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (isDir) {
                                if (leaf=="..")
				    mMenu.folder = parts.slice(0,-2).join('/')
                                else mMenu.folder = modelData
                            } else {
                                pView.patch.addModule(modelData,
						      mMenu.popOrigin.x - content.width/2,
						      mMenu.popOrigin.y - content.height/2);
                                mMenu.close();
                            }
                        }
                    }
                }
                highlight: Rectangle {
                    color: Style.menuLitColor
                }
                clip: true
		onModelChanged: mMenu.height = model.length * 14 + 13
		
            }
        }

        OhmPopup {
            id: delModuleMenu
            title: "Delete?"
            height: 50
            width: 46
	    scale: window.width / overlay.width * 0.7
            contents: OhmButton {
                x: Fn.centerInX(this,delModuleMenu)
                y: Fn.centerInY(this,delModuleMenu.body) - 5
                width: 45; height: 45
                imageUrl: "../ui/icons/delete.svg"
                border: 0
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

    property Component moduleDisplay: Item {
        function enter(){}
        function exit(){}
    }

    property alias contentItem: content
    property alias cableDragView: childCableDragView

    Component.onCompleted: {
        patch.view = pView;
    }

}
