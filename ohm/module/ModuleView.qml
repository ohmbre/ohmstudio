
import QtQuick 2.11
import QtQml.StateMachine 1.0 as SM
import QtQuick.Controls 2.4

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
    radius: Math.max(width/2,height/2)
    property double rext: radius + Style.jackExtension
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

	Rectangle {
	    id: display
	    x: parent.width*.20
	    y: parent.height*.20
	    width:parent.width*.6
	    height: parent.height*.55
	    color: 'black'
	    radius: parent.height*.015
	    opacity: 0
	    visible: false
	    clip: true
	    Loader {
		id: displayLoader
		anchors.fill: parent
		sourceComponent: pView.moduleDisplay
	    }
	}

	states: [
	    State {
		name: "controlMode"
		StateChangeScript { script: { forceCollapse(); displayLoader.item.enter(); }}
		PropertyChanges { target: moduleLabel; scale: 0.25*controller.scale;
				  topPadding:-92; leftPadding: -20; rightPadding: -20 }
		PropertyChanges { target: moduleMouseArea; enabled: false }
		PropertyChanges { target: mousePinch; drag.target: null; onPressAndHold: null }
		PropertyChanges { target: moduleView; radius: 5 
				  width: pView.width/scaler.max; height: pView.height/scaler.max }
		PropertyChanges { target: controller; opacity: 1.0; visible: true }
		PropertyChanges { target: displayLoader; sourceComponent: module.display }
		PropertyChanges { target: display; opacity: 1.0; visible: true }
	    },
	    State {
		name: "patchMode"
		StateChangeScript { script: { forceCollapse(); displayLoader.item.exit() }}
	    }
	]
	
	transitions: Transition {
	    ParallelAnimation {
		id: controlAnim
		NumberAnimation { target: moduleView; properties: "width,height,radius";
				  duration: 500; easing.type: Easing.InOutQuad }
		NumberAnimation { target: moduleLabel; properties: "scale,topPadding";
				  duration: 500; easing.type: Easing.InOutQuad }
		NumberAnimation { target: controller; properties: "opacity";
				  duration: 500; easing.type: Easing.InOutQuad }
		NumberAnimation { target: display; properties: "opacity";
				  duration: 500; easing.type: Easing.InOutQuad }
		
	    }
	}
	property alias controlAnim: controlAnim
	
	PathView {
	    id: controller
	    width: parent.width / scale; height: parent.height / scale
	    anchors.centerIn: parent
	    opacity: 0
	    interactive: false
	    scale: 6.75/scaler.max
	    model: module.cvs
	    delegate: Component {
		Column {
		    id: knobView
		    Image {
			id: knobIcon
			anchors.horizontalCenter: labelText.horizontalCenter
			width: 6; height: 1.14*width;
			source: "../ui/icons/knob.png"
			mipmap: true
			smooth: true
			
			Rectangle {
			    height: 1.65;
			    width: .4;
			    x: 2.55
			    color: '#3b3b3b';
			    radius: .2
			    rotation: 14*controlVolts
			    transformOrigin: Item.Bottom
			}
			MouseArea {
			    id: knobClick
			    enabled: controller.visible
			    anchors.fill: parent
			    onClicked: knobControl.open()
			}
			
			Popup {
			    id: knobControl
			    modal: true
			    focus: true
			    padding: 0
			    topMargin: 58
			    leftMargin: 52
			    x: -knobView.x
			    y: -knobView.y
			    width: 215
			    height: 107
			    background: Rectangle {
				anchors.fill: parent
				color: 'transparent'
				radius: 10
			    }
			    OhmText {
				x:knobControl.background.width-70
				y:knobControl.background.height-30
				text: controlVolts.toFixed(3)+' V'
				font.pixelSize: 12
				font.weight: Font.Bold
				horizontalAlignment: Text.AlignLeft
				color: Style.sliderColor
			    }
			    OhmText {
				x:35
				y:20
				text: knobReading
				font.pixelSize: 12
				font.weight: Font.Bold
				horizontalAlignment: Text.AlignLeft
				color: Style.sliderColor
			    }
			    Slider {
				id: knob
				rotation: -26
				value: controlVolts;
				from: -10; to: 10
				onValueChanged: {
				    controlVolts = value
				}
				anchors.fill: parent
				background: Rectangle {
				    x: knob.leftPadding; y: knob.topPadding + knob.availableHeight/2 - height / 2
				    implicitWidth: 5
				    implicitHeight: 100
				    width: knob.availableWidth
				    height: 5
				    color: Style.sliderColor
				    radius: 2
				    Rectangle {
					x: ((knob.visualPosition > .5) ? .5 : (knob.visualPosition+.02))*parent.width
					width: ((knob.visualPosition > .5) ? (knob.position-0.5) :
						(0.47-knob.visualPosition)) * parent.width
					height: parent.height
					color: Style.sliderLitColor
					radius: 2
				    }
				    Rectangle {
					x: parent.width/2-3; y:-3
					width: 4
					height:10
					color: Style.darkText
					radius: 2
				    }
				    Repeater {
					model: 11
					OhmText {
					    text: (index - 5)*2 + ((index==0||index==10)? 'V':'')
					    x: knob.leftPadding+2+index*parent.width/10.9-contentWidth/2
					    y: knob.topPadding
					    font.pixelSize: 7
					    color: Style.sliderColor
					}
				    }

				}
				handle: Rectangle {
				    x: knob.leftPadding + knob.visualPosition * (knob.availableWidth - width)
				    y: knob.topPadding + knob.availableHeight / 2 - height / 2
				    implicitWidth: 22
				    implicitHeight: 22
				    radius: 11
				    color: knob.pressed ? Style.sliderHandleLitColor: Style.sliderHandleColor
				    border.color: Style.buttonBorderColor
				}
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
		startX: .13*controller.width; startY: .2*controller.height
		PathLine { x: .13*controller.width; y: .835*controller.height }
		PathPercent { value: .333 }
		PathLine { x: .88*controller.width; y: .835*controller.height }
		PathPercent { value: .667 }
		PathLine { x: .88*controller.width; y: .2*controller.height }
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
        property double extra: Style.jackExtension * Math.max(inJackExtend,outJackExtend)+12
        width: parent.width + extra*2
        height: parent.height + extra*2
        x: -extra
        y: -extra
        visible: false
    }
    property alias perimeter: perimeter

    readonly property real minPadRadians: 0.1
    readonly property real maxSweepRadians: 1

    function computeJackAngles(jacks, sweep) {
	if (jacks.length = 0) return {}
	var angles = []
	var unknowns = []
	
	Fn.forEach(jacks, function(jack,j) {
	    var cbl = module.parent.lookupCableFor(jack)
	    if (cbl.cable) {
		var other = cbl.otherend.parent;
		var dx = module.x-other.x, dy = module.y-other.y
		var angle = (dx>0) ? (Math.PI-Math.atan(dy/dx)) : Math.atan(-dy/dx)
		angles.push({jack: jack, theta: angle, start: angle-sweep/2, end: angle+sweep/2})
	    } else unknowns.push(jack)
	});

	while (unknowns.length) {
	    var gaps = []
	    if (angles.length == 0)
		gaps.push({start:3*Math.PI/2, end:7*Math.PI/2, len: 2*Math.PI})
	    else {
		angles.sort(function(a,b) { return a.theta-b.theta })
		for (var a = 0; a < angles.length-1; a++) {
		    var gap = {start: angles[a].end, end: angles[a+1].start}
		    gap.len = gap.end - gap.start
		    gaps.push(gap)
		}
		var lastgap = {start: angles[angles.length-1].end, end: angles[0].start}
		lastgap.len = lastgap.end - lastgap.start + 2*Math.PI	    	    
		gaps.push(lastgap)
		gaps.sort(function (a,b) { return b.len-a.len })
	    }
	    var biggest = gaps[0];
	    var nfit = Math.max(1,Math.min(unknowns.length,Math.floor(biggest.len/sweep)))
	    var inc = biggest.len / nfit
	    for (var n = 0; n < nfit; n++) {
		var t = biggest.start + inc/2 + inc*n
		angles.push({jack:unknowns.shift(), theta: t, start: t-sweep, end: t+sweep})
	    }
	}

	var ret = {}
	for (var a = 0; a < angles.length; a++)
	    ret[angles[a].jack.label] = angles[a]
	return ret
    }

    
    property var inJackAngles: computeJackAngles(module.inJacks, inSweep)
    property var outJackAngles: computeJackAngles(module.outJacks, outSweep)
    property double inSweep: Math.min(Style.maxJackSweep, 2*Math.PI/module.inJacks.length)
    property double outSweep: Math.min(Style.maxJackSweep, 2*Math.PI/module.outJacks.length)
    
    Repeater {
        anchors.fill: parent
        model: module.inJacks
        InJackView {
            jack: modelData
	    theta: inJackAngles[modelData.label].theta
	    sweep: inSweep
            extend: inJackExtend
        }
    }

    Repeater {
        anchors.fill: parent
        model: module.outJacks
        OutJackView {
            jack: modelData
	    theta: outJackAngles[modelData.label].theta
	    sweep: outSweep
            extend: outJackExtend
        }
    }	
    
    Component.onCompleted: {
        module.view = moduleView;
        module.x = Qt.binding(function() { return moduleView.x - Fn.centerInX(moduleView, moduleView.parent);});
        module.y = Qt.binding(function() { return moduleView.y - Fn.centerInY(moduleView, moduleView.parent);});
    }

}
