import QtQuick 2.10
import "helpers.js" as F
import "."

Rectangle {
    id: moduleView
    property Module module
    property point coords
    property double jInScale: 1.0
    property double jOutScale: 1.7
    width: moduleLabel.implicitWidth + 14
    height: moduleLabel.implicitHeight + 14
    x: F.centerRectX(moduleView,parent) + coords.x
    y: F.centerRectY(moduleView,parent) + coords.y
    visible: true
    radius: 14
    border.width: 1.5
    border.color: Style.moduleBorderColor
    color: Style.moduleColor
    z: 1

    StyledText {
        id: moduleLabel
        //width: 60

        text: module.label

    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        drag.target: parent
        drag.axis: Drag.XAndYAxis
        //drag.smoothed: true
        propagateComposedEvents: true
        preventStealing: true
        onClicked: {
            //for (var i = 0; i < module.inJacks.length; i++)
            //    module.inJacks[i].view.scale = 25;

        }

    }

    readonly property real minPadRadians: 0.1
    readonly property real maxSweepRadians: 1

    Repeater {
        anchors.fill: parent
        model: module.inJacks
        JackView {
            jack: modelData
            bgColor: Style.jackInColor
            clearRadians: 2*Math.PI / module.inJacks.length
            sweepRadians: Math.min(clearRadians - minPadRadians, maxSweepRadians)
            centerRadians: index * clearRadians + Math.PI/2
            scaleX: jInScale * moduleView.width/2;
            scaleY: jInScale * moduleView.height/2;
        }
    }

    Repeater {
        anchors.fill: parent
        model: module.outJacks
        JackView {
            jack: modelData
            bgColor: Style.jackOutColor
            clearRadians: 2*Math.PI / module.outJacks.length
            sweepRadians: Math.min(clearRadians - minPadRadians, maxSweepRadians)
            centerRadians: index * clearRadians + Math.PI/2
            scaleX: jOutScale * moduleView.width/2;
            scaleY: jOutScale * moduleView.height/2;
        }
    }

    Component.onCompleted: {
        module.view = moduleView;
    }

}
