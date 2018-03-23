import QtQuick 2.10
import "../Helpers.js" as F
import ".."

Rectangle {
    id: moduleView
    property Module module
    property point coords
    property double inJackExtend: 2.7
    property double outJackExtend: 2.7
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
            for (var i = 0; i < module.inJacks.length; i++)
                F.dDump(module.inJacks[0].view.path)
            for (i = 0; i < module.outJacks.length; i++)
                F.dDump(module.outJacks[0].view.path)

            //module.inJacks[i].view.scale = 25;

        }

    }

    readonly property real minPadRadians: 0.1
    readonly property real maxSweepRadians: 1

    Repeater {
        anchors.fill: parent
        model: module.inJacks
        InJackView {
            jack: modelData
            index: index
            extend: inJackExtend
        }
    }

    Repeater {
        anchors.fill: parent
        model: module.outJacks
        OutJackView {
            jack: modelData
            index: index
            extend: outJackExtend
        }
    }

    Component.onCompleted: {
        module.view = moduleView;
    }

}
