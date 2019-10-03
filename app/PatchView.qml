import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQml 2.11

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
        onClicked: mMenu.popup(addModuleBtn)
    }

    OhmPopup {
        id: mMenu
        title: "Add Module"
        width: 95

        property point popOrigin: Qt.point(content.width/2, content.height/2)
        property string directory: ':/app/modules'
        property string match: '*Module.qml'
        onOpened: {
            body.contentLoader.item.forceActiveFocus()
            body.contentLoader.item.folder = mMenu.directory
            body.contentLoader.item.model = FileIO.listDir(mMenu.directory,match,":/app/modules")
        }
        contents: ListView {
            id: moduleList
            width: mMenu.width
            contentHeight: model.length * 13
            height: contentHeight
            keyNavigationEnabled: mMenu.opened
            focus: true
            property string folder: mMenu.directory
            property string match: mMenu.match
            model: FileIO.listDir(folder,match,":/app/modules")
            delegate: OhmText {
                width: mMenu.width
                height: 14
                property string path: modelData
                property var parts: modelData.split('/')
                property string leaf: parts[parts.length-1]
                property bool isDir: leaf == '..' || leaf.indexOf('.') == -1
                property string stem: parts.slice(0,-1).join('/')
                text: isDir ? leaf : leaf.replace(/Module\.qml$/,'')
                color: "black"
                horizontalAlignment: Text.AlignRight
                padding: 2
                rightPadding: 14
                Image {
                    source: 'qrc:/app/ui/icons/arrow.svg'
                    width: 8
                    height: 3.5
                    visible: isDir
                    horizontalAlignment: Text.AlignRight
                    y: 5.5
                    x: parent.width - 10
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (isDir) {
                            if (leaf=="..")
                                moduleList.folder = parts.slice(0,-2).join('/')
                            else moduleList.folder = path
                            moduleList.model = FileIO.listDir(moduleList.folder, moduleList.match, ":/app/modules")
                        } else {
                            pView.placeModule(path)

                            mMenu.close();
                        }
                    }
                }
            }

            property Component emptyFooter: Item {}
            footer: Item {}
            clip: true
            onModelChanged: {
                mMenu.height = model.length * 14 + 13
                mMenu.body.height =  model.length * 14
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
