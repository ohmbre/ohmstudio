import ohm 1.0

CV {
    objectName: "QuantCV"

    property double nth: 2
    property int steps: voltTicks.length
    onControlVoltsChanged: {
	if (controlVolts % 1 != 0)
	    controlVolts = Math.round(controlVolts);
    }
	
    stream: ''
    
}
