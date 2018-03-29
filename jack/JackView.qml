import QtQuick 2.10
import QtQuick.Shapes 1.11
import ".."
import "../Helpers.js" as F

Item {
    id: jackView
    property Jack jack
    property int position
    property int siblings
    property int direction
    property double extend

    property double clearRad: 2*Math.PI / siblings
    property double sweepRad: Math.min(clearRad - Style.minJackGap, Style.maxJackSweep)
    property double theta: direction * (position * clearRad + Math.PI/2)
    property double r: extend * Math.sqrt(Math.pow(moduleView.rxext*Math.cos(theta),2) +
                                 Math.pow(moduleView.ryext*Math.sin(theta),2))
    property color bgColor
    property color bgColorLit
    z: -2
    height: (Style.jackExtension + moduleView.radius) * 2 * Math.sin(sweepRad/2)
    width: r + Style.jackLabelGap + jackLabel.contentWidth

    Shape {
        id: jackShape
        width: r
        height: jackView.height
        containsMode: Shape.FillContains
        layer.samples: 4
        ShapePath {
            id: shapePath
            fillColor: bgColor
            strokeColor: "#00000000"
            startX: 0; startY: jackShape.height/2
            PathLine {
                id: linePath
                x: r * Math.cos(-sweepRad/2)
                y: jackShape.height
            }
            PathArc {
                id: arcPath
                radiusX: r
                radiusY: r
                x: r * Math.cos(sweepRad/2)
                y: 0
                direction: PathArc.Counterclockwise
            }
            PathLine {x: 0; y:jackShape.height/2}
        }

        MouseArea {
            id: jackPad
            anchors.fill: parent
            propagateComposedEvents: true
            preventStealing: true
            hoverEnabled: true
            drag.threshold: 0
            drag.target: patchView.edgeDragView.target
            /*states: [
                State {
                    name: "lit"
                    when: jackPad.containsMouse && jackShape.contains(Qt.point(jackPad.mouseX, jackPad.mouseY))
                    PropertyChanges { target: shapePath; fillColor: bgColorLit }
                }
            ]*/

            onPressed: function(event) {
                if (jackShape.contains(Qt.point(event.x, event.y))) {
                    var globPos = jackPad.mapToGlobal(event.x,event.y);
                    patchView.edgeDragView.dragStarted(globPos,jackView);
                }
            }
        }
    }

    StyledText {
        id: jackLabel
        text: jack.label;
        property color blend: Style.jackLabelColor
        color: Qt.rgba(blend.r, blend.g, blend.b, blend.a * extend);
        height: parent.height
        horizontalAlignment: Text.AlignLeft
        font.pixelSize: 8
        rotation: (Math.cos(theta) >= 0 ? 0 : 180)
        transformOrigin: Item.Center
        x: r + Style.jackLabelGap
    }

    transform: [
        Translate {
            x: moduleView.rx
            y: F.centerRectY(jackView, moduleView)
        },
        Rotation {
            origin.x: moduleView.rx
            origin.y: moduleView.ry
            axis.y: 0
            axis.x: 0
            axis.z: 1
            angle: -theta*180/Math.PI
        }
    ]

    Component.onCompleted: {
        jack.view = jackView;
        //F.dDump(jackView);
    }
}


