import ohm 1.0

CV {
    objectName: "QuantCV"

    property var choices
    onControlVoltsChanged: {
	controlVolts = Math.round(((controlVolts+5)/10)*choices.length)/choices.length*10-5
	updateControl(id, controlVolts)
    }
    stream: choices[
	Math.max(Math.min(Math.round(((controlVolts+5)/10)*choices.length),choices.length-1),0)
    ].toString()
    
    
}
