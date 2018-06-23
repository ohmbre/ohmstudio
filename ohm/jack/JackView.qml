import QtQuick 2.11
import QtQuick.Shapes 1.11

import ohm 1.0
import ohm.helpers 1.0
import ohm.ui 1.0

Item {
    id: jackView
    property Jack jack
    property int direction
    property double extend
    property double sweep
    property double theta: {
	var cableLookup = jack.parent.parent.lookupCableFor(modelData)
        if (cableLookup.cable) {
	    var otherModule = cableLookup.otherend.parent;
            var dx = module.x - otherModule.x
            var dy = module.y - otherModule.y;
            return (dx > 0) ? Math.atan(dy/dx) : Math.atan(-dy/dx)
        } else return direction * (position * clearRad + Math.PI/2)
    }
    property double r: extend * moduleView.rext
    property color bgColor
    property color bgColorLit
    property int arrowRotation

    height: moduleView.rext * 2 * Math.sin(sweep/2)
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
                x: r * Math.cos(-sweep/2)
                y: jackShape.height
            }
            PathArc {
                id: arcPath
                radiusX: 12
                radiusY: 12
                x: r * Math.cos(sweep/2)
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
            x: moduleView.radius
            y: Fn.centerInY(jackView, moduleView)
        },
        Rotation {
            origin.x: moduleView.width/2
            origin.y: moduleView.height/2
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
    }
}


