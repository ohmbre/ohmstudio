import QtQuick 2.10

import ohm 1.0
import ohm.helpers 1.0

Model {
    objectName: "CV"
    readonly property string id: Fn.uniqId()

    property string label

    property double controlVolts: 0
    onControlVoltsChanged: updateControl(id, controlVolts);
    
    property var inVolts: 0
    property var stream: '(add((%1), control(%2)))'.arg(inVolts).arg(id)
    property string knobReading: ''
    
    function toQML(indent) {
	return controlVolts.toString();
    }

    Component.onCompleted: {
	controlVoltsChanged.connect(userChanges);
    }
    
}
