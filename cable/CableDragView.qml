import QtQuick 2.10
import QtQuick.Shapes 1.11
import ".."
import "../Helpers.js" as F

Shape {
    id: cableDragView
    property JackView startJackView: null
    property JackView endJackView: null

    width: patchView.width
    height: patchView.height
    antialiasing: true
    layer.samples: 4

    property MouseArea dragPad;

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
                dragShape.startX: F.centerX(startJackView.parent) + startJackView.r * 0.8 * Math.cos(startJackView.theta);
                dragShape.startY: F.centerY(startJackView.parent) + startJackView.r * 0.8 * -Math.sin(startJackView.theta);
                destination.visible: true
                destination.x: cableDragView.mapFromItem(dragPad, dragPad.mouseX, dragPad.mouseY).x;
                destination.y: cableDragView.mapFromItem(dragPad, dragPad.mouseX, dragPad.mouseY).y;
                gravityOn: 1
            }

        }
    ]

    signal cableStarted(JackView jv)
    onCableStarted: function(jv) {
        var cableResult = patchView.patch.lookupCableFor(jv.jack);
        dragPad = jv.pad
        if (cableResult.cable) {
            patchView.patch.deleteCable(cableResult.cable);
            startJackView = cableResult.otherend.view;
            endJackView = jv;
            jv.dropTargeted = true;
        } else
            startJackView = jv;
        state = "dragging";
        dragPad.positionChanged.connect(cableDragView.cableMoved);
        dragPad.released.connect(cableDragView.cableDropped);
        animationOn = true;
    }

    signal cableMoved
    onCableMoved: {
        for (var m = 0; m < patchView.patch.modules.length; m++) {
            var mv = patchView.patch.modules[m].view;
            if (mv === startJackView.parent) continue;
            var mRelPos = dragPad.mapToItem(mv.perimeter, dragPad.mouseX, dragPad.mouseY);
            if (mv.perimeter.contains(mRelPos)) {
                var jacklist = [];
                if (startJackView.jack.dir === "inp") {
                    mv.state = "outJacksExtended";
                    jacklist = mv.module.outJacks;
                } else if (startJackView.jack.dir === "out") {
                    mv.state = "inJacksExtended";
                    jacklist = mv.module.inJacks;
                }
                for (var j = 0; j < jacklist.length; j++) {
                    if (patchView.patch.lookupCableFor(jacklist[j]).cable) continue;
                    var jv = jacklist[j].view;
                    var jRelPos = dragPad.mapToItem(jv.shape, dragPad.mouseX, dragPad.mouseY);
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
            } else {
                mv.state = "collapsed";
                if (endJackView !== null && endJackView.parent === mv) {
                    endJackView.dropTargeted = false;
                    endJackView = null;
                }
            }
        }
    }

    signal cableDropped
    onCableDropped: {
        dragPad.positionChanged.disconnect(cableDragView.cableMoved);
        dragPad.released.disconnect(cableDragView.cableDropped);
        state = "notdragging";
        animationOn = false;
        if (endJackView != null) {
            var cComponent = Qt.createComponent("Cable.qml");
            if (cComponent.status === Component.Ready) {
                var cData = {};
                cData[startJackView.jack.dir] = startJackView.jack;
                cData[endJackView.jack.dir] = endJackView.jack;
                var cObj = cComponent.createObject(patchView.patch, cData);
                patchView.patch.addCable(cObj);
                startJackView.parent.state = "collapsed";
                endJackView.parent.state = "collapsed";
            }
            endJackView.dropTargeted = false;
            endJackView = null;
        }
        startJackView = null;
        dragPad = null
    }


}

