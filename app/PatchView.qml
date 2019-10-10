import QtQuick 2.13
import QtQuick.Controls 2.5
import QtQml 2.11
import Fluid.Templates 1.0

Item {
    id: pView
    property Patch patch
    width: 320
    height: 240
    property alias moduleOverlay: moduleOverlay
    ModuleOverlay {
        id: moduleOverlay
    }

    Item {
        enabled: moduleOverlay.module == null
        id: content
        width: 1600
        height: 1200
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        ParallelAnimation {
            id: zoomPanAnim
            running: false
            NumberAnimation {id: xAnim; property: 'x';
                target: content; duration: 400}
            NumberAnimation {id: yAnim; property: 'y';
                target: content; duration: 400}
            NumberAnimation {property: 'zoom'; target: scaler;
                duration: 400; to: scaler.max}
        }
        onXChanged: {
            var topleft = content.mapFromItem(pView,0,0);
            var bottright = content.mapFromItem(pView,pView.width,pView.height);
            if (topleft.x < 0) content.x += topleft.x*scaler.zoom;
            else if (bottright.x > content.width)
                content.x -= (content.width-bottright.x)*scaler.zoom;
        }
        onYChanged: {
            var topleft = content.mapFromItem(pView,0,0);
            var bottright = content.mapFromItem(pView,pView.width,pView.height);
            if (topleft.y < 0) content.y += topleft.y*scaler.zoom;
            else if (bottright.y > content.height)
                content.y -= (content.height-bottright.y)*scaler.zoom;
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
                if (zoomPanAnim.running) return false;
                var oldZoom = zoom;
                var newZoom = zoom * (1 + zoomDelta);
                if (newZoom < min || newZoom > max) return false;
                zoom = newZoom;
                content.x += center.x*(oldZoom-zoom);
                content.y += center.y*(oldZoom-zoom);
                return true
            }
        }
        property alias scaler: scaler


        PinchArea {
            anchors.fill: parent
            onPinchUpdated: {
                pinch.accepted = scaler.zoomContent(
                            pinch.scale-pinch.previousScale,
                            Qt.point(pinch.startCenter.x, pinch.startCenter.y))
            }
            MouseArea {
                id: mousePinch
                hoverEnabled: true
                anchors.fill: parent
                drag.target: content
                propagateComposedEvents: false
                onWheel: wheel.accepted = scaler.zoomContent(wheel.angleDelta.y / 3200, Qt.point(wheel.x, wheel.y))

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

                CableDragView {id: childCableDragView; }

            }
        }


        OhmPopup {
            id: delModuleMenu
            title: "Delete?"
            height: 50
            width: 46
            scale: window.width / overlay.width * 0.7
            contents: OhmButton {
                x: centerInX(this,delModuleMenu)
                y: centerInY(this,delModuleMenu.body)
                verticalAlignment: Text.AlignBottom
                width: 26; height: 26
                padding: 0
                text: "×"
                font.pixelSize:27
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

    }

    OhmButton {
        id: addModuleBtn
        x: parent.width - 30; y: parent.height - 30
        width: 40; height: 40; radius: 20
        text: "+"
        font.pixelSize: 20
        font.weight: Font.DemiBold
        verticalAlignment: Text.AlignBottom
        onClicked: mMenu.visible = true
    }

    Rectangle {
        visible: false
        width: 100
        height: window.globalHeight
        x: window.globalWidth-width
        clip: true
        id: mMenu
        color: 'white'
        border.width: 2
        radius: 4
        border.color: 'black'
        ListView {
            anchors.fill: parent
            function listModules() {
                return FileIO.listDir(':/app','*Module.qml',":/app")
                       .filter(m => m !== ':/app/Module.qml' && m.endsWith('.qml'))
                       .map(fname => {
                                try {
                                    const obj = Qt.createQmlObject(FileIO.read(fname), pView.patch, 'qrc:/app/fake.qml')
                                    const label = obj.label
                                    obj.destroy()
                                    return {path: fname, label: label}
                                } catch (err) {
                                    console.log("Error in module",fname,":",err)
                                    const parts = fname.split('/')
                                    return {path: fname, label: parts[parts.length-1]}
                                }
                            })
                .sort((a,b) => a.label.toUpperCase() < b.label.toUpperCase() ? -1 : 1)
            }
            model: listModules()
            header: Rectangle {
                width: parent.width
                radius: 4
                height: 14
                color: 'black'
                OhmText {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                    color: 'white'
                    text: 'Add Module'
                }
                Rectangle {
                    x: 0; y: parent.height - 4
                    width: parent.width; height: 4
                    color: 'black'
                }

            }
            delegate: OhmText {
                width: parent.width
                height: 14
                text: modelData.label
                color: "black"
                horizontalAlignment: Text.AlignRight
                padding: 2
                rightPadding: 5
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        pView.placeModule(modelData.path)
                        mMenu.visible = false;
                    }
                }
            }
        }
    }

    function placeModule(path) {
        const outside = (p1,p2) => ((p1.x-26)>(p2.x+26))||((p2.x-26)>(p1.x+26))||((p1.y-18)>(p2.y+18))||((p2.y-18)>(p1.y+18))
        const fits = p => {
            for (let i = 0; i < pView.patch.modules.length; i++)
              if (!outside(p, Qt.point(pView.patch.modules[i].x, pView.patch.modules[i].y))) return false
            return true;
        }
        // whip it round in an archimedes spiral
        let t = 0
        let p = Qt.point(0,0)
        while (!fits(p)) {
            t += Math.PI/(t+1)
            p = Qt.point(13/9*t*Math.cos(t), t*Math.sin(t))
        }
        pView.patch.addModule(path, p.x, p.y);
    }

    property alias contentItem: content
    property alias cableDragView: childCableDragView

    Component.onCompleted: {
        patch.view = pView;
    }

}
