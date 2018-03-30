import QtQuick 2.10
import QtQuick.Shapes 1.11
import ".."
import "../Helpers.js" as F

Shape {
    id: edgeDragView
    property JackView startJackView: null
    property JackView endJackView: null
    property ModuleView startModuleView: startJackView ? startJackView.parent : null
    property ModuleView endModuleView: endJackView ? endJackView.parent : null

    width: patchView.width
    height: patchView.height
    antialiasing: true
    layer.samples: 4

    Rectangle{
        id: dest
        width: 5; height: 5; radius: 2.5
        z: 3
        visible: false
    }
    property alias destination: dest

    ShapePath {
        id: dragShape
        strokeWidth: 2.5
        fillColor: "transparent"
        joinStyle: ShapePath.RoundJoin
        strokeStyle: ShapePath.SolidLine

        PathCubic {
            id: dragCurve
        }
    }

    states: [
        State {
            name: "noStartNoEnd"
            PropertyChanges { target: dragShape; startX: 0; startY: 0; strokeColor: "transparent" }
            PropertyChanges { target: dragCurve; x: 0; y: 0; control1X: 0; control1Y: 0; control2X: 0; control2Y: 0 }
        },
        State {
            name: "startNoEnd"
            extend: "start"
            PropertyChanges {
                target: dragCurve
                x: F.centerX(destination); y: F.centerY(destination)
                control2X: F.centerX(destination); control2Y: F.centerY(destination)
            }
        },
        State {
            name: "startAndEnd"
            extend: "start"
            PropertyChanges {
                target: dragCurve
                x: F.centerX(endModuleView); y: F.centerY(endModuleView)
                control2X: Style.edgeControlStiffness * endJackView.r * Math.cos(endJackView.theta) + x
                control2Y: Style.edgeControlStiffness * endJackView.r * -Math.sin(endJackView.theta) + y
            }
        },
        State {
            name: "start"
            changes: [
                PropertyChanges {
                    target: dragShape;
                    strokeColor: Style.edgeColor
                    startX: F.centerX(startModuleView);
                    startY: F.centerY(startModuleView)
                },
                PropertyChanges {
                    target: dragCurve;
                    control1X: Style.edgeControlStiffness * startJackView.r * Math.cos(startJackView.theta) + dragShape.startX
                    control1Y: Style.edgeControlStiffness * startJackView.r * -Math.sin(startJackView.theta) + dragShape.startY
                }
            ]
        }
    ]

    signal edgeStarted(JackView jv)
    onEdgeStarted: function(jv) {
        function relPos() {
            return mapFromItem(jv.pad, jv.pad.mouseX, jv.pad.mouseY);
        }
        destination.x = Qt.binding(function() { return relPos().x - destination.width/2; });
        destination.y = Qt.binding(function() { return relPos().y - destination.height/2; });
        destination.visible = true;
        startJackView = jv;
        state = "startNoEnd";
        jv.pad.positionChanged.connect(edgeDragView.edgeMoved);
        jv.pad.released.connect(edgeDragView.edgeDropped);

    }

    signal edgeMoved
    onEdgeMoved: {
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
                    var jv = jacklist[j].view;
                    var jRelPos = sjp.mapToItem(jv.shape, sjp.mouseX, sjp.mouseY);
                    if (jv.shape.contains(jRelPos)) {
                        if (!jv.dropTargeted) {
                            jv.dropTargeted = true;
                            endJackView = jv;
                            state = "startAndEnd"
                        }
                    } else {
                        if (jv.dropTargeted) {
                            jv.dropTargeted = false;
                            state = "startNoEnd"
                            endJackView = null;
                        }
                    }
                }
            } else
                mv.state = "collapsed";
        }
    }

    signal edgeDropped
    onEdgeDropped: {
        startJackView.pad.positionChanged.disconnect(edgeDragView.edgeMoved);
        startJackView.pad.released.disconnect(edgeDragView.edgeDropped);
        destination.visible = false;
        destination.x = 0; destination.y = 0;
        state = "NoStartNoEnd";

        if (endJackView != null) {
            var ec = Qt.createComponent("Edge.qml");
            if (ec.status === Component.Ready) {
                var ed = {
                    "fromOutJack": ((startJackView.jack.jackDir === Constants.jack.dirOut) ? startJackView.jack : endJackView.jack),
                    "toInJack": ((startJackView.jack.jackDir === Constants.jack.dirIn) ? startJackView.jack : endJackView.jack)
                }
                var eo = ec.createObject(patchView.patch, ed);
                patchView.patch.edges.push(eo);
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

