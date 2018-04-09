import QtQuick 2.10
import QtQml.StateMachine 1.0 as SM

import ohm 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0
import ohm.helpers 1.0

Rectangle {
    id: moduleView
    property Module module
    property double inJackExtend: 0
    property double outJackExtend: 0

    x: Fn.centerInX(moduleView,parent)
    y: Fn.centerInY(moduleView,parent)
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

    NumberAnimation {
        id: extendAnim; target: moduleView; from: 0; to: 1;
        function run(on) { property = on; start(); }
    }
    NumberAnimation {
        id: collapseAnim; target: moduleView; from: 1; to: 0;
        function run(on) { property = on; start(); }
    }

    property SM.State nextState: (collapsed.active && module.inJacks.length && extendInputs)
                                 || (!extendOutputs.active && module.outJacks.length && extendOutputs)
                                 || collapsed

    SM.StateMachine {
        id: stateMachine
        initialState: collapsed
        running: true
        SM.State {
            id: collapsed
            SM.SignalTransition { signal: moduleMouseArea.clicked; targetState: nextState }
            SM.SignalTransition { signal: forceInputExtend; targetState: extendInputs }
            SM.SignalTransition { signal: forceOutputExtend; targetState: extendOutputs }
        }
        SM.State {
            id: extendInputs
            SM.SignalTransition { signal: moduleMouseArea.clicked; targetState: nextState }
            SM.SignalTransition { signal: forceCollapse; targetState: collapsed }
            onEntered: extendAnim.run("inJackExtend")
            onExited: collapseAnim.run("inJackExtend")
        }
        SM.State {
            id: extendOutputs
            SM.SignalTransition { signal: moduleMouseArea.clicked; targetState: nextState }
            SM.SignalTransition { signal: forceCollapse; targetState: collapsed; }
            onEntered: extendAnim.run("outJackExtend")
            onExited: collapseAnim.run("outJackExtend")
        }

    }
    signal forceInputExtend
    signal forceOutputExtend
    signal forceCollapse

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
        height: (parent.height > parent.width) ? (parent.height - radius ) : parent.height
        width: (parent.width > parent.height) ? (parent.width - radius ) : parent.width
        x: Fn.centerInX(moduleMouseArea, moduleMouseArea.parent)
        y: Fn.centerInY(moduleMouseArea, moduleMouseArea.parent)
        drag.target: parent
        drag.smoothed: true
        propagateComposedEvents: true
        preventStealing: true
        onPressAndHold: patchView.confirmDeleteModule(module);
        pressAndHoldInterval: 800
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
        x += module.coords.x
        y += module.coords.y
        xChanged.connect(function () { module.coords.x = Math.round(x - Fn.centerInX(moduleView,parent))})
        yChanged.connect(function () { module.coords.y = Math.round(y - Fn.centerInY(moduleView,parent))})

    }

}
