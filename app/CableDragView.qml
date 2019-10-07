import QtQuick 2.12
import QtQuick.Shapes 1.11

Shape {
    id: cableDragView
    property JackView startJackView: null
    property JackView endJackView: null

    width: pView.width
    height: pView.height

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
            x: centerX(destination) - destination.dot.width/2
            y: centerY(destination) - destination.dot.height/2
            control1X: dragShape.startX; control1Y: dragShape.startY + gravityOn * 100
            control2X: x; control2Y: y + gravityOn * 100;
            Behavior on control2X {
                id: springX
                enabled: animationOn
                SpringAnimation { spring: .1; damping: 0.03}
            }
            Behavior on control2Y {
                id: springY
                enabled: animationOn
                SpringAnimation { spring: .1; damping: 0.03}
            }
        }
        property alias dragCurve: dragCurve
    }
    property alias dragShape: dragShape
    property bool animationOn: false
    property real gravityOn: 0
    Behavior on gravityOn { NumberAnimation { duration: 300 } }

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
                dragShape.strokeColor: '#F55D3E'
                dragShape.startX: startJackView.anchor2X
                dragShape.startY: startJackView.anchor2Y
                destination.visible: true
                destination.x: dragPad.mouseX + dragPad.parentModuleView.x - 10
                destination.y: dragPad.mouseY + dragPad.parentModuleView.y - 10
                gravityOn: 1
            }

        }
    ]

    signal cableStarted(JackView jv)
    onCableStarted: function(jv) {
        dragPad = jv.pad
        if (jv.jack.hasCable && jv.jack.dir == 'inp') {
            startJackView = jv.jack.cable.out.view
            jv.jack.cable.destroy()
            startJackView.extend()
            endJackView = jv
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
        forEach(pView.patch.modules, function(module) {
            var mv = module.view;
            if (mv === startJackView.parent) return;
            var mRelPos = dragPad.mapToItem(mv.perimeter, dragPad.mouseX, dragPad.mouseY);
            if (mv.perimeter.contains(mRelPos)) {
                var jacklist = [];
                if (startJackView.jack.dir === "inp") {
                    jacklist = mv.module.outJacks;
                } else if (startJackView.jack.dir === "out") {
                    jacklist = mv.module.inJacks;
                }
                forEach(jacklist, function(jack) {
                    if (jack.hasCable && jack.dir === 'inp') {
                        jack.view.collapse()
                        return;
                    }
                    var jv = jack.view;
                    jv.extend()
                    var jRelPos = dragPad.mapToItem(jv, dragPad.mouseX, dragPad.mouseY);
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
                });
            } else {
                mv.collapseAll();
                if (endJackView !== null && endJackView.parent === mv) {
                    endJackView.dropTargeted = false;
                    endJackView = null;
                }
            }
        });
    }

    signal cableDropped
    onCableDropped: {
        dragPad.positionChanged.disconnect(cableDragView.cableMoved);
        dragPad.released.disconnect(cableDragView.cableDropped);
        state = "notdragging";
        animationOn = false;
        if (endJackView != null) {
            var cableComponent = Qt.createComponent("qrc:/app/Cable.qml");
            if (cableComponent.status === Component.Ready) {
                var cableData = {};
                cableData[startJackView.jack.dir] = startJackView.jack;
                cableData[endJackView.jack.dir] = endJackView.jack;
                var cable = cableComponent.createObject(cableData['out'], cableData);

                startJackView.parent.collapseAll();
                endJackView.parent.collapseAll();
            } else
                console.log("error creating cable:", cComponent.errorString());
            endJackView.dropTargeted = false;
            endJackView = null;
        }
        startJackView = null;
        dragPad = null
    }

}

