import QtQuick
import QtQuick.Controls
import QtQml

Item {
    id: pView
    
    property alias moduleOverlay: moduleOverlay
    property Patch patch: Patch {}
    
    function newPatch() {
        patch.destroy()
        patch = patchComponent.createObject(pView, {})
    }
    
    Timer {
        id: autoSaveTimer
        interval: 2000; running: false; repeat: true
        onTriggered: savePatch(pView.patch, 'autosave.json')
    }
    
    Component.onCompleted: {
        loadModules(pView);
        mlv.model = listModules()
        if (!loadPatch(patch, 'autosave.json'))
            loadPatch(patch, 'qrc:/app/defaultpatch.json')
        autoSaveTimer.start()
    }
    
    function confirmDeleteModule(module) {
        delModule.candidate = module;
        delModule.popup();
    }
    
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
                if (mMenu.visible && mMenu.contains(mMenu.mapFromItem(mousePinch,center.x,center.y))) return false;
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
            id: mousePinch
            anchors.fill: parent
            onPinchUpdated: (pinch) => {
                pinch.accepted = scaler.zoomContent(
                            pinch.scale-pinch.previousScale,
                            Qt.point(pinch.startCenter.x, pinch.startCenter.y))
            }
            MouseArea {

                anchors.fill: parent
                drag.target: content
                propagateComposedEvents: false
                onWheel: (wheel) => {
                    wheel.accepted = scaler.zoomContent(wheel.angleDelta.y / 3200, Qt.point(wheel.x, wheel.y))
                }

                Repeater {
                    id: moduleList
                    model: patch.modules
                    ModuleView {
                        module: modelData
                    }
                }

                Repeater {
                    id: cableList
                    model: patch.cables
                    CableView {
                        cable: modelData
                    }
                }

                onClicked: {
                    mMenu.visible = false;
                }

                CableDragView {id: childCableDragView; }

            }
        }

        Menu {
            id: delModule
            property Module candidate
            width: 70
            Menu {
                title: "Delete?"
                font.weight: Font.Bold
                enabled: false
            }
            MenuItem { 
                text: 'Yes' 
                onTriggered: {
                    patch.deleteModule(delModule.candidate)
                    delModule.close()
                }                
            }
            MenuItem {
                text: 'No'
                onTriggered: delModule.close()
            }
            delegate: MenuItem {
                id: menuItem
                arrow: Item {}
                contentItem: OhmText {
                    text: menuItem.text
                    font.pixelSize: 14
                }
            }
        }
    }

    OhmButton {
        id: addModuleBtn
        x: xpct(100) - 26; y: ypct(100) - 26
        width: 40; height: 40; radius: 20; padding: 1
        text: "+"
        font.pixelSize: 15
        font.weight: Font.Bold
        onClicked: mMenu.visible = true
        border: 4
    }
    
    Rectangle {
        id: mMenu
        visible: false
        width: 100
        height: ypct(100)
        x: xpct(100)-width
        clip: true
        color: 'white'
        border.width: 2
        radius: 4
        border.color: 'black'
        ListView {
            id: mlv
            anchors.fill: parent
            property string tag: ''

            function chosen(m) {
                if (m.isTag) {
                    tag = m.label
                } else {
                    pView.placeModule(m)
                    mMenu.visible = false;
                    tag = ''
                }
                model = listModules(tag)
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
                width: parent? parent.width : 0
                height: 14
                text: modelData.label
                color: "black"
                horizontalAlignment: Text.AlignRight
                padding: 2
                rightPadding: 5
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: mlv.chosen(modelData)
                }
            }
            onFocusChanged: {
                if (!focus)
                    visible = false
            }

        }
    }

    function placeModule(m) {
        const outside = (p1,p2) => ((p1.x-26)>(p2.x+26))||((p2.x-26)>(p1.x+26))||((p1.y-18)>(p2.y+18))||((p2.y-18)>(p1.y+18))
        const fits = p => {
            for (let i = 0; i < pView.patch.modules.length; i++)
              if (!outside(p, Qt.point(pView.patch.modules[i].x, pView.patch.modules[i].y))) return false
            return true;
        }
        // archimedes spiral
        let t = 0
        let p = Qt.point(0,0)
        while (!fits(p)) {
            t += Math.PI/(t+1)
            p = Qt.point(13/9*t*Math.cos(t), t*Math.sin(t))
        }
        pView.patch.addModule(m, {x:p.x, y:p.y});
    }

    property alias cableDragView: childCableDragView


}
