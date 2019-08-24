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
                if (zoom > 3.5 && zoomDelta > 0)
                    forEach(patch.modules, function(m) {
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
                    forEach(patch.modules, function(m) {
                        if (m.view.innerModule.state == "controlMode" && !m.view.innerModule.controlAnim.running) {
                            m.view.innerModule.state = "patchMode";
                            return -1;
                        }
                    });
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
        height: 200
        scale: 2
        transformOrigin: Item.BottomRight

        property point popOrigin: Qt.point(content.width/2, content.height/2)
        property string directory: 'modules'
        property string match: '*Module.qml'
        onOpened: {
            body.contentLoader.item.forceActiveFocus()
            body.contentLoader.item.folder = mMenu.directory
            body.contentLoader.item.model = HWIO.listDir(mMenu.directory,match)
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
            model: HWIO.listDir(folder,match)
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
                            moduleList.model = HWIO.listDir(moduleList.folder, moduleList.match)
                        } else {
                            pView.patch.addModule(path, 80, 60);
                            mMenu.close();
                        }
                    }
                }
            }
            highlight: Rectangle {
                color: Style.menuLitColor
                radius: 2
            }
            property Component emptyFooter: Item {}
            property Component uploadFooter: OhmButton {
                id: mFooter
                font.pixelSize: 6
                border: 2; padding: 6
                x: (parent.width - width)/2
                height: 13; z: 3
                clip: true
                text: 'Upload New'
                onClicked: {
                    HWIO.upload(mMenu.folder)
                    mMenu.close()
                }
            }
            property real footerHeight: 0
            footer: emptyFooter
            footerPositioning: ListView.OverlayFooter
            clip: true
            onModelChanged: {
                mMenu.height = model.length * 14 + 13 + footerHeight
                mMenu.body.height =  model.length * 14
            }
        }
    }

    property alias contentItem: content
    property alias cableDragView: childCableDragView

    Component.onCompleted: {
        patch.view = pView;
    }

}
