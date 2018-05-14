import QtQuick 2.10
import QtQml.StateMachine 1.0 as SM
import QtQuick.Controls 2.3

import ohm 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0
import ohm.helpers 1.0
import ohm.ui 1.0

Rectangle {
    id: moduleView
    property Module module
    property double inJackExtend: 0
    property double outJackExtend: 0

    x: Fn.centerInX(this, this.parent) + module.x
    y: Fn.centerInY(this, this.parent) + module.y;
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
    smooth: true

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
        id: ioState
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

    Item {
	id: innerModule
	anchors.fill: parent
	
	OhmText {
            id: moduleLabel
            text: module.label
            padding: Style.moduleLabelPadding
            anchors.fill: parent
            color: Style.moduleLabelColor
            Component.onCompleted: {
		moduleView.height = contentHeight + padding*2;
		moduleView.width = contentWidth + padding*2;
            }
	}

	property point storedSize
	states: [
	    State {
		name: "controlMode"
		StateChangeScript { script: { forceCollapse(); }}
		PropertyChanges { target: moduleLabel; scale: 0.35*controller.scale; topPadding:-60 }
		PropertyChanges { target: moduleMouseArea; enabled: false }
		PropertyChanges { target: mousePinch; drag.target: null }
		PropertyChanges { target: moduleView; radius: 5 
				  width: pView.width/scaler.max; height: pView.height/scaler.max }
		PropertyChanges { target: controller; opacity: 1.0; visible: true }
	    },
	    State {
		name: "patchMode"
	    }
	]
	
	transitions: Transition {
	    ParallelAnimation {
		NumberAnimation { target: moduleView; properties: "width,height,radius";
				  duration: 300; easing.type: Easing.InOutQuad }
		NumberAnimation { target: moduleLabel; properties: "scale,topPadding";
				  duration: 300; easing.type: Easing.InOutQuad }
		NumberAnimation { target: controller; properties: "opacity";
				  duration: 300; easing.type: Easing.InOutQuad }
		
	    }
	}

	PathView {
	    id: controller
	    width: parent.width / scale; height: parent.height / scale
	    anchors.centerIn: parent
	    opacity: 0
	    interactive: false
	    scale: 6.75/scaler.max
	    model: module.cvs
	    delegate: Component {
		id: knobView
		Column {
		    Image {
			id: knobIcon
			anchors.horizontalCenter: labelText.horizontalCenter
			width: 6; height: 1.14*width;
			source: "../ui/icons/knob.png"
			mipmap: true
			smooth: true
			Dial {
			    id: cvDial
			    width: 3.3; height: 3.3;
			    from: -5; to: 5; value: control
			    onValueChanged: control = value;
			    background: Rectangle {
				width: 3.3; height: 3.3;
				color: 'transparent'
				radius: 1.65
				x: 1.1
			    }
			    handle: Rectangle {
				height: 1.65;
				width: .4;
				x: 2.55
				color: '#3b3b3b';
				radius: .2
				rotation: cvDial.angle
				transformOrigin: Item.Bottom
			    }
			}
		    }
		    OhmText {
			id: labelText
			width: knobIcon.width
			text: label
			color: Style.moduleLabelColor
			font.pixelSize: 1
			scale: 1.5
		    }
		}
	    }
	    pathItemCount: undefined
	    offset: .5
	    path: Path {
		startX: .15*controller.width; startY: .2*controller.height
		PathLine { x: .15*controller.width; y: .78*controller.height }
		PathPercent { value: .333 }
		PathLine { x: .85*controller.width; y: .78*controller.height }
		PathPercent { value: .667 }
		PathLine { x: .85*controller.width; y: .2*controller.height }
		PathPercent { value: 1 }
	    }
	}
    }
    property alias innerModule: innerModule

    MouseArea { // around innerModule and perimeter
        id: moduleMouseArea
        height: (parent.height > parent.width) ? (parent.height - radius ) : parent.height
        width: (parent.width > parent.height) ? (parent.width - radius ) : parent.width
        x: Fn.centerInX(moduleMouseArea, moduleMouseArea.parent)
        y: Fn.centerInY(moduleMouseArea, moduleMouseArea.parent)
        drag.target: parent
        drag.smoothed: true
        propagateComposedEvents: true
        preventStealing: true
        onPressAndHold: pView.contentItem.confirmDeleteModule(module);
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
        module.x = Qt.binding(function() { return moduleView.x - Fn.centerInX(moduleView, moduleView.parent);});
        module.y = Qt.binding(function() { return moduleView.y - Fn.centerInY(moduleView, moduleView.parent);});
    }

}
