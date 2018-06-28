
import QtQuick 2.11
import QtQml.StateMachine 1.0 as SM
import QtQuick.Controls 2.4

import ohm 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0
import ohm.helpers 1.0
import ohm.ui 1.0

Item {
    id: mView
    property Module module
    x: Fn.centerInX(this, this.parent) + module.x
    y: Fn.centerInY(this, this.parent) + module.y
    z: 1
    width: 48; height: 32
  
    property alias outline: outline
    
    OhmRect {
	id: outline
	x:0; y:0; z: 0
	size: Qt.size(parent.width, parent.height)
	radius: height/2
	color: Style.moduleColor
	border: Style.moduleBorderWidth
	borderColor: Style.moduleBorderColor
        onPressAndHold: pView.contentItem.confirmDeleteModule(module)
	onClicked: {
	    var anyExtended = false
	    for (var j = 0; j < module.nJacks; j++)
		if (module.jack(j).view.extension > 0) {
		    anyExtended = true
		    break
		}
	
	    if (anyExtended) collapseAll()
	    else extendAll()
	}
	dragTarget: parent
    }
   
    function collapseAll() {
	for (var j = 0; j < module.nJacks; j++)
	    module.jack(j).view.collapse()
    }

    function extendAll() {
	for (var j = 0; j < module.nJacks; j++)
	    module.jack(j).view.extend()
    }

    Item {
	id: innerModule
	anchors.fill: parent

	    OhmText {
		id: moduleLabel
		x: mView.height/5
		y: mView.height/5
		width: mView.width - mView.height/2.5
		height: mView.height - mView.height/2.5
		text: module.label
		padding: 0
		fontSizeMode: Text.Fit
		color: Style.moduleLabelColor
		font.family: asapFont.name
		font.weight: Font.Medium
		font.pixelSize: 10
		minimumPixelSize: 8
		maximumLineCount: 2
		elide: Text.ElideNone
		wrapMode: Text.WordWrap
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
		PropertyChanges { target: mousePinch; drag.target: null; onPressAndHold: null }
		PropertyChanges { target: outline; radius: 5; eventsEnabled: false
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
		NumberAnimation { target: outline; properties: "width,height,radius";
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
	    visible: false
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
			    parent: Overlay.overlay
			    x: Math.round((parent.width - width) / 2)
			    y: Math.round((parent.height - height) / 2.2)
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

    Rectangle {
        id: perimeter
        width: parent.width + Style.jackExtension*2
        height: parent.height + Style.jackExtension*2
        x: -Style.jackExtension
        y: -Style.jackExtension
        visible: false
    }
    property alias perimeter: perimeter

    function computeJackShapes(jacks) {
	var mH = mView.height
	var mW = mView.width
	var mR = mH/2
	var cstart = mW/2 - mR
	var tstart = cstart + Math.PI * mR
	var perim = tstart + mW/2 - mR
	var sweep = perim / jacks.length

	function posToPoint(pos,ext) {
	    if (pos <= cstart) 
		return Qt.point(mW/2-mR-pos,mR+ext)
	    else if (pos < tstart) {
		var theta = (pos-cstart) / mR
		return Qt.point(-(mR+ext) * Math.sin(theta), (mR+ext) * Math.cos(theta))
	    } else 
		return Qt.point(pos-tstart,-(mR+ext))
	}

	var shapeData = {}
	for (var j = 0, start = 0; j < jacks.length; j++, start += sweep) {
	    var path = []
	    var xt = (jacks[j].view ? (jacks[j].view.extension * Style.jackExtension) : 0)
	    var center = start + sweep/2
	    var s = center - Math.min((j==0) ? (sweep/2) : (sweep/2-0.35), Style.maxJackSweep)
	    var e = center + Math.min((j==jacks.length-1) ? (sweep/2) : (sweep/2-0.35), Style.maxJackSweep)
	    if (s < cstart) {
		if (e > cstart)
		    path.push({p:posToPoint(cstart,0), a: 0, d: 0})
		if (e > tstart)
		    path.push({p:posToPoint(tstart,0), a: mR, d: 0})
	    } else if (s < tstart && e > tstart)
		path.push({p:posToPoint(tstart,0), a: mR, d: 0})
	    path.push({p:posToPoint(e,0), a: (e > cstart && e < tstart) ? mR : 0, d: 0})
	    path.push({p:posToPoint(e,xt), a: 0, d: 0})
	    if (e > tstart) {
		if (s < tstart)
		    path.push({p:posToPoint(tstart,xt), a:0, d: 1})
		if (s < cstart)
		    path.push({p:posToPoint(cstart,xt), a:mR+xt, d: 1})
	    } else if (e > cstart && s < cstart)
		path.push({p:posToPoint(cstart,xt), a:mR+xt, d: 1})
	    path.push({p:posToPoint(s,xt), a: (s > cstart && s < tstart) ? (mR+xt) : 0, d:1})
	    path.push({p:posToPoint(s,0), a: 0, d: 1})
	    shapeData[jacks[j]] = { start: posToPoint(s,0), path: path,
				    center: posToPoint(center,0),
				    theta: Fn.clip(-Math.PI/2, (center-cstart)/mR - Math.PI/2, Math.PI/2) }
	}
	
	    
	return shapeData
    }
	
    
    property var inJackShapes: computeJackShapes(module.inJacks)
    property var outJackShapes: computeJackShapes(module.outJacks)
    
    Repeater {
        anchors.fill: parent
        model: module.inJacks
        InJackView {
            jack: modelData
	    shapeData: inJackShapes[modelData]
	    posRef: Qt.point(mView.height/2, mView.height/2)
        }
    }

    Repeater {
        anchors.fill: parent
        model: module.outJacks
        OutJackView {
            jack: modelData
	    shapeData: outJackShapes[modelData]
	    posRef: Qt.point(mView.width - mView.height/2, mView.height/2)
        }
    }	
    
    Component.onCompleted: {
        module.view = mView;
        module.x = Qt.binding(function() { return mView.x - Fn.centerInX(mView, mView.parent);});
        module.y = Qt.binding(function() { return mView.y - Fn.centerInY(mView, mView.parent);});
    }

}
