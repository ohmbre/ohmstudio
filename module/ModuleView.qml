import QtQuick 2.10
import "../Helpers.js" as F
import ".."

Rectangle {
    id: moduleView
    property Module module
    property point coords
    property double inJackExtend: 0
    property double outJackExtend: 0

    x: F.centerRectX(moduleView,parent) + coords.x
    y: F.centerRectY(moduleView,parent) + coords.y

    z: 1
    width: moduleLabel.implicitWidth + 14
    height: moduleLabel.implicitHeight + 14
    radius: 14
    color: Style.moduleColor
    border.color: Style.moduleBorderColor
    border.width: 1.5
    antialiasing: true

    Behavior on inJackExtend { SmoothedAnimation { velocity: 200 } }
    Behavior on outJackExtend { SmoothedAnimation { velocity: 200 } }
    property string initNextState: (module.inJacks.length ? "inJacksExpanded" :
                                                 (module.outJacks.length ? "outJacksExpanded" :
                                                                        "collapsed"))
    property string nextState: initNextState

    states: [
        State {
            name: "inJacksExpanded"
            PropertyChanges {
                target: moduleView
                inJackExtend: 1
                outJackExtend: 0
                nextState: module.outJacks.length ? "outJacksExpanded" : "collapsed"
            }
        },
        State {
            name: "outJacksExpanded"
            PropertyChanges {
                target: moduleView
                inJackExtend: 0
                outJackExtend: 1
                nextState: "collapsed"
            }
        },
        State {

            name: "collapsed"
            PropertyChanges {
                id: collapsed
                target: moduleView
                inJackExtend: 0
                outJackExtend: 0
                nextState: initNextState
            }
        }
    ]

    transitions: [
        Transition {
            to: "*"
            NumberAnimation { properties: "inJackExtend,outJackExtend"; easing.type: Easing.InQuad }
        }
    ]



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
            moduleView.state = nextState
        }
    }

    readonly property real minPadRadians: 0.1
    readonly property real maxSweepRadians: 1

    Repeater {
        anchors.fill: parent
        model: module.inJacks
        InJackView {
            jack: modelData
            position: index
            siblings: module.inJacks.length
            extend: inJackExtend
        }
    }

    Repeater {
        anchors.fill: parent
        model: module.outJacks
        OutJackView {
            jack: modelData
            position: index
            siblings: module.outJacks.length
            extend: outJackExtend
        }
    }

    Component.onCompleted: {
        module.view = moduleView;
    }

}
