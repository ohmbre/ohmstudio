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
    width: 50
    height: 50
    property double rx: width/2
    property double ry: height/2
    property double rxext: rx + Style.jackExtension
    property double ryext: ry + Style.jackExtension
    radius: Math.min(rx,ry)
    color: Style.moduleColor
    border.color: Style.moduleBorderColor
    border.width: Style.moduleBorderWidth
    antialiasing: true

    Behavior on inJackExtend { SmoothedAnimation { velocity: 200 } }
    Behavior on outJackExtend { SmoothedAnimation { velocity: 200 } }
    property string initNextState: (module.inJacks.length ? "inJacksExtended" :
                                                 (module.outJacks.length ? "outJacksExtended" :
                                                                        "collapsed"))
    property string nextState: initNextState

    states: [
        State {
            name: "inJacksExtended"
            PropertyChanges {
                target: moduleView
                inJackExtend: 1
                outJackExtend: 0
                nextState: module.outJacks.length ? "outJacksExtended" : "collapsed"
            }
        },
        State {
            name: "outJacksExtended"
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
        padding: Style.moduleLabelPadding
        anchors.fill: parent

        Component.onCompleted: {
            moduleView.height = contentHeight + padding*2;
            moduleView.width = contentWidth + padding*2;
        }
    }

    MouseArea { // around module label and rounded rect
        id: moduleMouseArea
        anchors.fill: parent
        drag.target: parent
        drag.smoothed: true
        propagateComposedEvents: true
        preventStealing: true
        onClicked: {
            moduleView.state = nextState
        }
    }

    Rectangle {
        id: perimeter
        property double extra: Style.jackExtension * Math.max(inJackExtend,outJackExtend)
        width: parent.width + extra*2
        height: parent.height + extra*2
        x: -extra
        y: -extra
        visible: false
    }
    property alias perimeter: perimeter

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
