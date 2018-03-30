import QtQuick 2.10
import QtQuick.Shapes 1.11
import ".."
import "../Helpers.js" as F

Shape {
    id: cableDragView
    property JackView startJackView: null
    property JackView endJackView: null
    property ModuleView startModuleView: startJackView ? startJackView.parent : null
    property ModuleView endModuleView: endJackView ? endJackView.parent : null

    width: patchView.width
    height: patchView.height
    antialiasing: true
    layer.samples: 4

    Item{
        id: destination
        width: 5; height: 5;
        z: 3
        visible: false
        Rectangle {
            id: dot
            width: 5; height: 5; radius: 2.5
            visible: parent.visible
            x: -width/2; y: -height/2
        }
        property alias dot: dot
    }
    property alias destination: destination

    ShapePath {
        id: dragShape
        strokeWidth: 2.5
        fillColor: "transparent"
        joinStyle: ShapePath.RoundJoin
        strokeStyle: ShapePath.SolidLine

        PathCubic {
            id: dragCurve
            x: F.centerX(destination) - destination.dot.width/2
            y: F.centerY(destination) - destination.dot.height/2
            control1X: dragShape.startX; control1Y: dragShape.startY + gravityOn * Style.cableGravity;
            control2X: x; control2Y: y + gravityOn * Style.cableGravity;
            Behavior on control2X { enabled: animationOn; id: springX; SpringAnimation { spring: 1; damping: 0.05} }
            Behavior on control2Y { enabled: animationOn; id: springY; SpringAnimation { spring: 1; damping: 0.05} }
        }
        property alias dragCurve: dragCurve
    }
    property alias dragShape: dragShape
    property bool animationOn: false
    property real gravityOn: 0
    Behavior on gravityOn { NumberAnimation { duration: 1 } }

    states: [
        State {
            name: "notdragging"
            PropertyChanges {
                target: cableDragView
                dragShape.strokeColor: "transparent"
                destination.visible: false
                gravityOn: 0
            }
        },
        State {
            name: "dragging"
            PropertyChanges {
                target: cableDragView
                dragShape.strokeColor: Style.cableColor
                dragShape.startX: F.centerX(startModuleView) + startJackView.r * 0.8 * Math.cos(startJackView.theta);
                dragShape.startY: F.centerY(startModuleView) + startJackView.r * 0.8 * -Math.sin(startJackView.theta);
                destination.visible: true
                destination.x: cableDragView.mapFromItem(startJackView.pad, startJackView.pad.mouseX, startJackView.pad.mouseY).x;
                destination.y: cableDragView.mapFromItem(startJackView.pad, startJackView.pad.mouseX, startJackView.pad.mouseY).y;
                gravityOn: 1
            }

        }
    ]

    signal cableStarted(JackView jv)
    onCableStarted: function(jv) {
        if (patchView.patch.getCable(jv.jack)) return;
        startJackView = jv;
        state = "dragging";
        jv.pad.positionChanged.connect(cableDragView.cableMoved);
        jv.pad.released.connect(cableDragView.cableDropped);
        animationOn = true;
    }

    signal cableMoved
    onCableMoved: {
        for (var m = 0; m < patchView.patch.modules.length; m++) {
            var mv = patchView.patch.modules[m].view;
            if (mv === startModuleView) continue;
            var sjp = startJackView.pad;
            var mRelPos = sjp.mapToItem(mv.perimeter, sjp.mouseX, sjp.mouseY);
            if (mv.perimeter.contains(mRelPos)) {
                var jacklist = [];
                if (startJackView.jack.jackDir === Constants.jack.dirIn) {
                    mv.state = "outJacksExtended";
                    jacklist = mv.module.outJacks;
                } else if (startJackView.jack.jackDir === Constants.jack.dirOut) {
                    mv.state = "inJacksExtended";
                    jacklist = mv.module.inJacks;
                }
                for (var j = 0; j < jacklist.length; j++) {
                    if (patchView.patch.getCable(jacklist[j])) continue;
                    var jv = jacklist[j].view;
                    var jRelPos = sjp.mapToItem(jv.shape, sjp.mouseX, sjp.mouseY);
                    if (jv.shape.contains(jRelPos)) {
                        if (!jv.dropTargeted) {
                            jv.dropTargeted = true;
                            endJackView = jv;
                        }
                    } else {
                        if (jv.dropTargeted) {
                            jv.dropTargeted = false;
                            endJackView = null;
                        }
                    }
                }
            } else
                mv.state = "collapsed";
        }
    }

    signal cableDropped
    onCableDropped: {
        startJackView.pad.positionChanged.disconnect(cableDragView.cableMoved);
        startJackView.pad.released.disconnect(cableDragView.cableDropped);
        state = "notdragging";
        animationOn = false;

        if (endJackView != null) {
            var ec = Qt.createComponent("Cable.qml");
            if (ec.status === Component.Ready) {
                var ed = {
                    "fromOutJack": ((startJackView.jack.jackDir === Constants.jack.dirOut) ? startJackView.jack : endJackView.jack),
                    "toInJack": ((startJackView.jack.jackDir === Constants.jack.dirIn) ? startJackView.jack : endJackView.jack)
                }
                var eo = ec.createObject(patchView.patch, ed);
                patchView.patch.cables.push(eo);
                startModuleView.state = "collapsed";
                endModuleView.state = "collapsed";
            }
            endJackView.dropTargeted = false;
            endJackView = null;
        }
        startJackView = null;
        console.log("dropped");
    }


}

