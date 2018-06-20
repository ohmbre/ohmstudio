import QtQuick 2.11
import QtQuick.Shapes 1.11

import ohm 1.0
import ohm.helpers 1.0
import ohm.ui 1.0

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
    property int arrowRotation

    height: (Style.jackExtension + moduleView.radius) * 2 * Math.sin(sweepRad/2)
    width: r + Style.jackLabelGap + jackLabel.contentWidth
    z: -1
    Shape {
        id: jackShape
        width: r
        height: jackView.height
        containsMode: Shape.FillContains
        layer.samples: 4
        z: -2
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
                radiusX: rxext
                radiusY: ryext
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
            onPressed: function(event) {
                if (jackShape.contains(Qt.point(event.x, event.y)))
                    pView.cableDragView.cableStarted(jackView);
            }
        }
    }
    property alias shape: jackShape
    property alias path: shapePath
    property alias pad: jackPad

    OhmText {
        id: jackLabel
        text: jack.label
        property color blend: Style.jackLabelColor
        color: Qt.rgba(blend.r, blend.g, blend.b, blend.a * extend);
        height: parent.height
        horizontalAlignment: Text.AlignLeft
        font.pixelSize: 8
        rotation: (Math.cos(theta) >= 0 ? 0 : 180)
        transformOrigin: Item.Center
        x: r + Style.jackLabelGap
    }

    Image {
        source: "../ui/icons/squiggle.svg"
        x: jackLabel.x - width - 2
        y: Fn.centerInY(this,this.parent);
        rotation: arrowRotation
        width: 10
        height: 4
        smooth: true
    }




    transform: [
        Translate {
            x: moduleView.rx
            y: Fn.centerInY(jackView, moduleView)
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

    property bool dropTargeted: false
    onDropTargetedChanged: {
        if (dropTargeted) shapePath.fillColor = bgColorLit;
        else shapePath.fillColor = bgColor;
    }

    Component.onCompleted: {
        jack.view = jackView;
        if (!Qt.jacks) Qt.jacks = [jackView];
        else Qt.jacks.push(jackView);
        //Fn.dDump(jackView);
    }
}


