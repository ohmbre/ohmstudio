import QtQuick 2.10

import ohm 1.0

Model {
    objectName: "CV"

    property string label
    property double controlVolts: 0
    property var voltTicks: [-8, -7, -6, -5, -4, -3, -2, -1,  0,
			          1,  2,  3,  4,  5,  6,  7,  8]
    property var inVolts: 0
    property var voltsToValue: function(volts) {return volts}
    property var stream: add(inVolts, controlVolts)

    function toQML(indent) {
	return controlVolts.toString();
    }

    Component.onCompleted: {
	controlVoltsChanged.connect(userChanges);
    }
    
}
