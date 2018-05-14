import ohm 1.0

CV {
    objectName: "LogScaleCV"

    property double nth: 2
    property int steps: streams.length
    property var streams: [-5,-4,-3,-2,-1,0,1,2,3,4,5];
    onControlChanged: {
	if (control % 1 != 0)
	    control = Math.round(countrol);
    }
	
    cv: index(streams,min(max(add(round(voltage),control,5),0),9))
    
}
